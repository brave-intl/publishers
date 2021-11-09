# typed: ignore
# Registers a promo registration for each verified channel for a publisher
class Promo::AssignPromoToChannelService < BaseApiClient
  include PromosHelper

  attr_reader :channel

  MAX_ATTEMPTS = 3

  def initialize(channel:, promo_id: active_promo_id, attempt_count: 0)
    @channel = channel
    @promo_id = promo_id
    @attempt_count = attempt_count
  end

  def perform
    return if !channel.verified? || channel.promo_registration.present?
    result = register_channel(channel)
    if result.nil? && @attempt_count < MAX_ATTEMPTS
      Promo::RegisterChannelForPromoJob.set(wait: 30.minutes).perform_later(channel_id: @channel.id, attempt_count: @attempt_count + 1) and return
    elsif result.nil? && @attempt_count >= MAX_ATTEMPTS
      return
    end

    referral_code = result[:referral_code]
    should_update_promo_server = result[:should_update_promo_server]
    begin
      if referral_code.present?
        promo_registration = PromoRegistration.new(channel_id: channel.id,
          promo_id: @promo_id,
          kind: PromoRegistration::CHANNEL,
          publisher_id: channel.publisher_id,
          referral_code: referral_code)

        success = promo_registration.save!
        if success
          PromoMailer.new_channel_registered_2018q1(channel.publisher, channel).deliver_later
          Promo::ChannelOwnerUpdater.new(publisher_id: channel.publisher_id, referral_code: referral_code).perform if should_update_promo_server
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      require "sentry-raven"
      Rails.logger.error("#{self.class.name} perform: #{referral_code} channel_id: #{channel.id} exception: #{e}")
      Raven.extra_context referral_code: referral_code
      Raven.capture_exception("Promo::PublisherChannelsRegistrar #perform error: #{e}")
    end
  rescue Faraday::Error::ClientError
    # When the owner is "no-ugp" the promo server will return 409.
    nil
  end

  def register_channel(channel)
    return register_channel_offline if perform_promo_offline?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.body = request_body(channel)
      request.url("/api/1/promo/publishers")
    end

    {
      referral_code: JSON.parse(response.body)["referral_code"],
      should_update_promo_server: false
    }
  rescue Faraday::Error::ClientError => e
    if e.response[:status] == 409
      change_ownership(channel)
    end
  rescue Faraday::Error => e
    require "sentry-raven"
    Rails.logger.error("Promo::PublisherChannelsRegistrar #register_channel error: #{e}")
    Raven.capture_exception("Promo::PublisherChannelsRegistrar #register_channel error: #{e}")
    nil
  end

  def change_ownership(channel)
    Rails.logger.warn("Promo::PublisherChannelsRegistrar #register_channel returned 409, channel already registered.  Using Promo::RegistrationGetter to get the referral_code.")

    # Get the referral code
    registration = Promo::RegistrationGetter.new(publisher: channel.publisher, channel: channel).perform

    {
      referral_code: registration["referral_code"],
      should_update_promo_server: registration["owner_id"] != channel.publisher_id
    }
  rescue Faraday::Error::ClientError
    nil
  end

  def register_channel_offline
    Rails.logger.info("Promo::PublisherChannelsRegistrar #register_channel offline.")
    {
      referral_code: offline_referral_code,
      should_update_promo_server: false
    }
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end

  def request_body(channel)
    case channel.details_type
    when "SiteChannelDetails"
      site_request_body(channel)
    else
      channel_request_body(channel)
    end
  end

  def channel_request_body(channel)
    {
      owner_id: channel.publisher_id,
      promo: @promo_id,
      channel: channel.channel_id,
      title: channel.publication_title,
      channel_type: channel.type_display.downcase,
      thumbnail_url: channel.details.thumbnail_url,
      description: nil
    }.to_json
  end

  def site_request_body(channel)
    {
      owner_id: channel.publisher_id,
      promo: @promo_id,
      channel: channel.channel_id,
      title: channel.publication_title,
      channel_type: "website"
    }.to_json
  end
end

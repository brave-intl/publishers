# Gets the referral code associated with a channel + publisher combo
class PromoRegistrationGetter < BaseApiClient
  include PromosHelper

  def initialize(publisher:, channel:, promo_id: active_promo_id)
    @publisher = publisher
    @channel = channel
    @promo_id = promo_id

    if !publisher_owners_channel
      raise PublisherChannelMismatchError.new("Cannot retrieve referral code becausse publisher #{publisher.id} does not own channel #{channel.id}.")
    end
  end

  def perform
    return perform_offline if perform_promo_offline?
    # Returns an array of publisher referral_codes, 1 for each promo
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/1/promo/publishers?channel=#{@channel.channel_id}")
    end
    registrations =  JSON.parse(response.body)
    referral_code = referral_code_for_promo_id(registrations)
    
    if should_update_channel_owner_on_promo_server(registrations)
      PromoChannelOwnerUpdater.new(publisher_id: @publisher.id, referral_code: referral_code).perform
    end
    
    referral_code
  rescue Faraday::Error => e
    require "sentry-raven"
    Rails.logger.error("PromoRegistrationGetter #perform error: #{e}")
    Raven.capture_exception("PromoRegistrationGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PromoRegistrationGetter offline.")

    registrations =
    [
      {
      "referral_code" => offline_referral_code,
      "promo" => "#{@promo_id}",
      "publisher" => "#{@channel.channel_id}",
      "name" => "#{@channel.publication_title}",
      },
      {
      "referral_code" => offline_referral_code,
      "promo" => "free-bats-2018q2",
      "publisher" => "#{@channel.channel_id}",
      "name" => "#{@channel.publication_title}",
      }
    ]
    referral_code = referral_code_for_promo_id(registrations)
  end

  class PublisherChannelMismatchError < RuntimeError; end

  class NoReferralCodeError < RuntimeError; end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end

  def publisher_owners_channel
    @publisher.channels.include?(@channel)
  end

  def should_update_channel_owner_on_promo_server(registrations)
    owner_on_promo_server = registrations[0]["owner_id"]
    if owner_on_promo_server != @publisher.id
      return true
    else
      return false
    end
  end

  def referral_code_for_promo_id(registrations)
    registrations.each do |registration|
      if registration["promo"] == active_promo_id
        return registration["referral_code"]
      end
      raise NoReferralCodeError.new("No referral_code has been registered for channel #{@channel.id} for promo #{@promo_id}")
    end
  end
end
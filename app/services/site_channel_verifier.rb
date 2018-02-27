require 'publishers/fetch'

# Request verification from Eyeshade. Sets the matching
# If the brave_publisher_id (domain) has previously been verified, you can't reverify (for now)
# TODO: Rate limit
class SiteChannelVerifier < BaseApiClient
  include Publishers::Fetch

  attr_reader :attended, :channel, :verified_channel, :verified_channel_id

  # attended: Passed through to Eyeshade; affects verbosity
  def initialize(attended: true, channel:)
    @attended = attended
    @channel = channel
    raise UnsupportedChannelType.new unless @channel && @channel.details.is_a?(SiteChannelDetails)
  end

  def perform
    return true if channel.verified?
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    # Will raise in case of error.
    response = connection.get do |request|
      request.params["backgroundP"] = "true" if !attended
      request.url("/v1/owners/#{URI.escape(channel.publisher.owner_identifier)}/verify/#{channel.details.brave_publisher_id}")
    end
    response_hash = JSON.parse(response.body)
    @verified_channel_id = response_hash["verificationId"]

    if response_hash["status"] != "success" || verified_channel_id.blank? || channel.id != verified_channel_id
      channel.verification_failed!
      return false
    end

    # Channel should have been verified through a call to PATCH /api/owners/:owner_id/channels/:channel_id/verifications
    # from eyeshade, so we won't update it here, just reload it
    channel.reload

    @verified_channel = channel

    verified_channel_post_verify
  end

  def perform_offline
    Rails.logger.info("SiteChannelVerifier bypassing eyeshade and performing locally.")
    @verified_channel_id = verify_offline_publisher_id

    if verified_channel_id.blank?
      channel.verification_failed!
      return false
    end

    update_verified_on_channel_offline

    unless channel.id == verified_channel_id
      channel.verification_failed!
      return false
    end

    verified_channel_post_verify
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def update_verified_on_channel_offline
    raise "#{verified_channel_id} missing" if verified_channel_id.blank?

    @verified_channel = Channel.find(verified_channel_id)
    return if @verified_channel.verified?

    verified_channel.verification_succeeded!

    verified_channel_post_verify

  rescue ActiveRecord::RecordNotFound => e
    require "sentry-raven"
    Raven.capture_exception(e)
  end

  def verified_channel_post_verify
    PublisherMailer.verification_done(verified_channel).deliver_later
    if PublisherMailer.should_send_internal_emails?
      PublisherMailer.verification_done_internal(verified_channel).deliver_later
    end
    SlackMessenger.new(message: "*#{verified_channel.publication_title}* verified by #{verified_channel.publisher.name} (#{verified_channel.publisher.email}); id=#{verified_channel.id}").perform
  end

  def verify_offline_publisher_id
    Rails.logger.info("PublisherVerifier offline by #{channel.details.verification_method}")

    case channel.details.verification_method
      when "dns_record"
        verify_offline_publisher_id_dns
      when "public_file"
        verify_offline_publisher_id_public_file
      when "github"
        verify_offline_publisher_id_public_file
      when "wordpress"
        verify_offline_publisher_id_public_file
      when "support_queue"
        verify_offline_publisher_id_support_queue
      else
        Rails.logger.info("PublisherVerifier unknown verification_method: #{channel.details.verification_method}")
        nil
    end
  end

  def verify_offline_publisher_id_support_queue
    nil
  end

  def verify_offline_publisher_id_dns
    require "dnsruby"
    resolver = Dnsruby::Resolver.new
    message = resolver.query(channel.details.brave_publisher_id, "TXT")
    answer = message.answer
    return nil if answer.blank?

    answer.each do |answer_part|
      next if !answer_part.respond_to?(:strings) || answer_part.strings.blank?
      answer_part.strings.each do |string|
        token_match = /^brave\-ledger\-verification\=([a-zA-Z0-9]+)$/.match(string)
        next if !token_match || !token_match[1]
        Rails.logger.info("Found token on #{channel.details.brave_publisher_id}: #{token_match[1]}")
        dns_channel = Channel.joins(:site_channel_details).find_by("site_channel_details.brave_publisher_id": channel.details.brave_publisher_id, "site_channel_details.verification_token": token_match[1])
        if dns_channel
          return dns_channel.id
        else
          Rails.logger.warn("Verification token didn't match any channels.")
        end
      end
    end
    nil
  rescue Dnsruby::NXDomain
    Rails.logger.warn("Dnsruby::NXDomain")
    nil
  end

  def verify_offline_publisher_id_public_file
    generator = SiteChannelVerificationFileGenerator.new(site_channel: channel)
    uri = URI("https://#{channel.details.brave_publisher_id}/.well-known/#{generator.filename}")
    response = fetch(uri: uri)
    if response.code == "200"
      token_match = /#{channel.details.verification_token}/.match(response.body)
      if token_match
        Rails.logger.warn("verify_offline_publisher_id_public_file: Token Found")
        channel.id
      else
        Rails.logger.warn("verify_offline_publisher_id_public_file: Token Mismatch")
        nil
      end
    else
      Rails.logger.warn("verify_offline_publisher_id_public_file: Not Net::HTTPSuccess")
      nil
    end
  rescue Publishers::Fetch::RedirectError, Publishers::Fetch::ConnectionFailedError => e
    Rails.logger.warn("verify_offline_publisher_id_public_file: #{e.message}")
    nil
  end

  # If the publisher previously has been verified, you can't reverify (for now)
  class VerificationIdMismatch < RuntimeError
  end

  class UnsupportedChannelType < RuntimeError
  end
end

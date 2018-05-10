require 'publishers/fetch'

class SiteChannelVerifier < BaseService
  include Publishers::Fetch

  attr_reader :channel, :verified_channel, :verified_channel_id

  def initialize(channel:)
    @channel = channel
    raise UnsupportedChannelType.new unless @channel && @channel.details.is_a?(SiteChannelDetails)
  end

  def perform
    return true if channel.verified?
    @verified_channel_id = verify_publisher_id

    if verified_channel_id.blank?
      channel.verification_failed!
      return false
    end

    update_verified_on_channel

    unless channel.id == verified_channel_id
      channel.verification_failed!
      return false
    end

    true
  end

  private

  def update_verified_on_channel
    require "publishers/restricted_channels"

    raise "#{verified_channel_id} missing" if verified_channel_id.blank?

    @verified_channel = Channel.find(verified_channel_id)
    return if @verified_channel.verified?

    if Publishers::RestrictedChannels.restricted?(verified_channel)
      verified_channel.verification_awaiting_admin_approval!
      # TODO Send notifications to admins
      return
    end

    verified_channel.verification_succeeded!
    verified_channel_post_verify

  rescue ActiveRecord::RecordNotFound => e
    require "sentry-raven"
    Raven.capture_exception(e)
  end

  def verified_channel_post_verify
    MailerServices::VerificationDoneEmailer.new(verified_channel: verified_channel).perform
    SlackMessenger.new(message: "*#{verified_channel.publication_title}* verified by #{verified_channel.publisher.name} (#{verified_channel.publisher.email}); id=#{verified_channel.id}").perform

    # Let eyeshade know about the new Publisher
    begin
      PublisherChannelSetter.new(publisher: @publisher).perform
    rescue => e
      # TODO: Retry if it fails
      require "sentry-raven"
      Raven.capture_exception(e)
    end
  end

  def verify_publisher_id
    Rails.logger.info("PublisherVerifier by #{channel.details.verification_method}")

    case channel.details.verification_method
      when "dns_record"
        verify_publisher_id_dns
      when "public_file"
        verify_publisher_id_public_file
      when "github"
        verify_publisher_id_public_file
      when "wordpress"
        verify_publisher_id_public_file
      when "support_queue"
        verify_publisher_id_support_queue
      else
        raise UnsupportedVerificationMethod.new("PublisherVerifier unknown verification_method:  #{channel.details.verification_method}")
    end
  end

  def verify_publisher_id_support_queue
    nil
  end

  def verify_publisher_id_dns
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
          Rails.logger.debug("Verification token didn't match any channels.")
        end
      end
    end
    nil
  rescue Dnsruby::NXDomain
    Rails.logger.debug("Dnsruby::NXDomain")
    nil
  end

  def verify_publisher_id_public_file
    generator = SiteChannelVerificationFileGenerator.new(site_channel: channel)
    uri = URI("https://#{channel.details.brave_publisher_id}/.well-known/#{generator.filename}")
    response = fetch(uri: uri)
    if response.code == "200"
      token_match = /#{channel.details.verification_token}/.match(response.body)
      if token_match
        Rails.logger.debug("verify_publisher_id_public_file: Token Found")
        channel.id
      else
        Rails.logger.debug("verify_publisher_id_public_file: Token Mismatch")
        nil
      end
    else
      Rails.logger.debug("verify_publisher_id_public_file: Not Net::HTTPSuccess")
      nil
    end
  rescue Publishers::Fetch::RedirectError, Publishers::Fetch::ConnectionFailedError => e
    Rails.logger.debug("verify_publisher_id_public_file: #{e.message}")
    nil
  end

  # If the publisher previously has been verified, you can't reverify (for now)
  class VerificationIdMismatch < RuntimeError
  end

  class UnsupportedChannelType < RuntimeError
  end

  class UnsupportedVerificationMethod < RuntimeError
  end
end

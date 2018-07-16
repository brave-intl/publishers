require 'publishers/fetch'

class SiteChannelVerifier < BaseService
  include Publishers::Fetch

  attr_reader :has_admin_approval, :channel, :verification_details

  # has_admin_approval signifies that an admin is manually initiating verification and
  # confirming the request is legit. do NOT run it automatically!
  def initialize(has_admin_approval: false, channel:)
    @has_admin_approval = has_admin_approval
    @channel = channel
    raise UnsupportedChannelType.new unless @channel && @channel.details.is_a?(SiteChannelDetails)
  end

  def perform
    return true if channel.verified?
    return false if channel.verification_awaiting_admin_approval? && !has_admin_approval

    verification_result = verify_site_channel
    
    if verification_result == false
      channel.verification_failed!(verification_details)
      return false
    elsif channel.needs_admin_approval? && !has_admin_approval
      channel.verification_awaiting_admin_approval!
      return false
    else
      channel.verification_succeeded!(has_admin_approval)
      verified_channel_post_verify
    end

    true
  end

  private

  def update_verified_on_channel
    verified_channel.verification_succeeded!(has_admin_approval)
    verified_channel_post_verify
  end

  def verified_channel_post_verify
    MailerServices::VerificationDoneEmailer.new(verified_channel: channel).perform
    SlackMessenger.new(message: "*#{channel.publication_title}* verified by owner #{channel.publisher.owner_identifier}; id=#{channel.details.channel_identifier}").perform

    # Let eyeshade know about the new Publisher
    begin
      PublisherChannelSetter.new(publisher: channel.publisher).perform
    rescue => e
      # TODO: Retry if it fails
      require "sentry-raven"
      Raven.capture_exception(e)
    end
  end

  def verify_site_channel
    Rails.logger.info("PublisherVerifier by #{channel.details.verification_method}")

    case channel.details.verification_method
      when "dns_record"
        verify_site_channel_dns
      when "public_file"
        verify_site_channel_public_file
      when "github"
        verify_site_channel_public_file
      when "wordpress"
        verify_site_channel_public_file
      else
        raise UnsupportedVerificationMethod.new("PublisherVerifier unknown verification_method:  #{channel.details.verification_method}")
    end
  end

  def verify_site_channel_dns
    require "dnsruby"
    resolver = Dnsruby::Resolver.new
    message = resolver.query(channel.details.brave_publisher_id, "TXT")
    answer = message.answer

    if answer.blank?
      @verification_details = "no_txt_records"
      return false
    end

    answer.each do |answer_part|
      next if !answer_part.respond_to?(:strings) || answer_part.strings.blank?
      answer_part.strings.each do |string|
        token_match = /^brave\-ledger\-verification\=([a-zA-Z0-9]+)$/.match(string)
        next if !token_match || !token_match[1]
        Rails.logger.info("Found token on #{channel.details.brave_publisher_id}: #{token_match[1]}")
        if channel.details.verification_token == token_match[1]
          return true
        else
          @verification_details = "token_incorrect_dns"
          Rails.logger.debug("Found incorrect channel for channel #{channel.id}")
          return false
        end
      end
    end
    @verification_details = "token_not_found_dns"    
    false
  rescue Dnsruby::NXDomain
    Rails.logger.debug("Dnsruby::NXDomain")
    @verification_details = "domain_not_found"
    return false
  end

  def verify_site_channel_public_file
    generator = SiteChannelVerificationFileGenerator.new(site_channel: channel)
    uri = URI("https://#{channel.details.brave_publisher_id}/.well-known/#{generator.filename}")
    response = fetch(uri: uri)
    if response.code == "200"
      token_match = /#{channel.details.verification_token}/.match(response.body)
      if token_match
        Rails.logger.debug("verify_site_channel_public_file: Token Found")
        true
      else
        Rails.logger.debug("verify_site_channel_public_file: Token Mismatch")
        @verification_details = "token_not_found_public_file"
        false
      end
    else
      Rails.logger.debug("verify_site_channel_public_file: Not Net::HTTPSuccess")
      @verification_details = "no_https"
      false
    end
  rescue Publishers::Fetch::RedirectError => e
    Rails.logger.debug("verify_site_channel_public_file: #{e.message}")
    @verification_details = "too_many_redirects"
    false
  rescue Publishers::Fetch::ConnectionFailedError => e
    Rails.logger.debug("verify_site_channel_public_file: #{e.message}")
    @verification_details = "connection_failed"
    false
  end

  class UnsupportedChannelType < RuntimeError
  end

  class UnsupportedVerificationMethod < RuntimeError
  end
end
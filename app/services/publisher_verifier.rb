require 'publishers/fetch'

# Request verification from Eyeshade. Sets the matching
# If the publisher previously has been verified, you can't reverify (for now)
# TODO: Rate limit
class PublisherVerifier < BaseApiClient
  include Publishers::Fetch

  attr_reader :attended, :brave_publisher_id, :publisher, :verified_publisher, :verified_publisher_id

  # publisher is optional. If given, service will raise errors if the provided publisher's verification token
  # doesn't match the one found on the domain.
  # attended: Passed through to Eyeshade; affects verbosity
  def initialize(attended: true, brave_publisher_id:, publisher: nil)
    @attended = attended
    @brave_publisher_id = brave_publisher_id
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    # Will raise in case of error.
    response = connection.get do |request|
      request.params["backgroundP"] = "true" if !attended
      request.url("/v1/publishers/#{brave_publisher_id}/verify")
    end
    response_hash = JSON.parse(response.body)
    @verified_publisher_id = response_hash["verificationId"]
    return false if response_hash["status"] != "success" || verified_publisher_id.blank?
    update_verified_on_publishers
    assert_publisher_matches_verified_id! if publisher
  end

  def perform_offline
    Rails.logger.info("PublisherVerifier bypassing eyeshade and performing locally.")
    @verified_publisher_id = verify_offline_publisher_id
    return false if verified_publisher_id.blank?
    update_verified_on_publishers
    assert_publisher_matches_verified_id! if publisher
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def assert_publisher_matches_verified_id!
    return true if publisher.id == verified_publisher_id
    raise VerificationIdMismatch.new("Publisher UUID / verificationId mismatch: #{publisher.id} / #{verified_publisher_id}")
  end

  def update_verified_on_publishers
    raise "#{verified_publisher_id} missing" if verified_publisher_id.blank?

    publishers_to_unverify = Publisher
      .where(brave_publisher_id: brave_publisher_id, verified: true)
      .where.not(id: verified_publisher_id)
    @verified_publisher = Publisher.find_by(brave_publisher_id: brave_publisher_id, id: verified_publisher_id)
    verified_publisher_changed = (verified_publisher && verified_publisher.verified == false)
    return if publishers_to_unverify.none? && !verified_publisher_changed

    Publisher.transaction do
      publishers_to_unverify.update_all(verified: false) if publishers_to_unverify.any?
      verified_publisher.update_attribute(:verified, true) if verified_publisher_changed
    end
    verified_publisher_post_verify if verified_publisher_changed
  end

  def verified_publisher_post_verify
    PublisherMailer.verification_done(verified_publisher).deliver_later
    if PublisherMailer.should_send_internal_emails?
      PublisherMailer.verification_done_internal(verified_publisher).deliver_later
    end
    SlackMessenger.new(message: "*#{verified_publisher}* verified by #{verified_publisher.name} (#{verified_publisher.email}); id=#{verified_publisher.id}").perform
  end

  def verify_offline_publisher_id
    Rails.logger.info("PublisherVerifier offline by #{publisher.verification_method}")

    case publisher.verification_method
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
        Rails.logger.info("PublisherVerifier unknown verification_method: #{publisher.verification_method}")
        nil
    end
  end

  def verify_offline_publisher_id_support_queue
    nil
  end

  def verify_offline_publisher_id_dns
    require "dnsruby"
    resolver = Dnsruby::Resolver.new
    message = resolver.query(brave_publisher_id, "TXT")
    answer = message.answer
    return nil if answer.blank?

    answer.each do |answer_part|
      next if !answer_part.respond_to?(:strings) || answer_part.strings.blank?
      answer_part.strings.each do |string|
        token_match = /^brave\-ledger\-verification\=([a-zA-Z0-9]+)$/.match(string)
        next if !token_match || !token_match[1]
        Rails.logger.debug("Found token on #{brave_publisher_id}: #{token_match[1]}")
        dns_publisher = Publisher.find_by(brave_publisher_id: brave_publisher_id, verification_token: token_match[1])
        if dns_publisher
          return dns_publisher.id
        else
          Rails.logger.warn("Verification token didn't match any Publishers.")
        end
      end
    end
    nil
  rescue Dnsruby::NXDomain
    Rails.logger.warn("Dnsruby::NXDomain")
    nil
  end

  def verify_offline_publisher_id_public_file
    generator = PublisherVerificationFileGenerator.new(publisher: publisher)
    uri = URI("https://#{brave_publisher_id}/.well-known/#{generator.filename}")
    response = fetch(uri: uri)
    if response.code == "200"
      token_match = /#{publisher.verification_token}/.match(response.body)
      if token_match
        Rails.logger.warn("verify_offline_publisher_id_public_file: Token Found")
        publisher.id
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
end

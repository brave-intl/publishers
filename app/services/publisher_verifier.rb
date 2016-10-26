# Request verification from Eyeshade
# TODO: Rate limit
class PublisherVerifier < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if ENV["API_EYESHADE_OFFLINE"]
    # Will raise in case of error.
    response = connection.get do |request|
      request.url("/v1/publishers/#{publisher.brave_publisher_id}/verify")
    end
    response_hash = JSON.parse(response.body)
    return false if response_hash["status"] != "success"
    if publisher.id != response_hash["verificationId"]
      raise VerificationIdMismatch.new("Publisher UUID / verificationId mismatch: #{publisher.id} / #{response_hash['verificationId']}")
    end
    publisher.verified = true
    publisher.save!
  end

  def perform_offline
    Rails.logger.info("PublisherVerifier bypassing eyeshade and performing locally.")
    require "dnsruby"
    resolver = Dnsruby::Resolver.new
    domain = publisher.brave_publisher_id
    Rails.logger.info("DNS query: #{domain}, TXT")
    message = resolver.query(publisher.brave_publisher_id, "TXT")
    answer = message.answer
    return false if answer.blank?
    desired_string = PublisherDnsRecordGenerator.new(publisher: publisher).perform
    answer.each do |answer_part|
      next if answer_part.strings.blank?
      if answer_part.strings.any? { |string| string == desired_string }
        publisher.verified = true
        publisher.save!
      end
    end
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  # If the publisher previously has been verified, you can't reverify (for now)
  class VerificationIdMismatch < RuntimeError
  end
end

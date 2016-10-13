# Request verification from Eyeshade
# TODO: Rate limit
class PublisherVerifier
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    # Will raise in case of error.
    response = connection.get do |request|
      request.url("/v1/publishers/#{publisher.brave_publisher_id}/verify")
    end
    response_hash = JSON.parse(response.body)
    return false if response_hash["status"] != "success"
    require "pry"; binding.pry
    if publisher.id != response_hash["verificationId"]
      raise VerificationIdMismatch.new("Publisher UUID / verificationId mismatch: #{publisher.id} / #{response_hash['verificationId']}")
    end
    publisher.verified = true
    publisher.save!
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def connection
    @connection ||= begin
      require "faraday"
      Faraday.new(url: api_base_uri) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response(:logger, Rails.logger)
        faraday.use(Faraday::Response::RaiseError)
      end
    end
  end

  # If the publisher previously has been verified, you can't reverify (for now)
  class VerificationIdMismatch < RuntimeError
  end
end

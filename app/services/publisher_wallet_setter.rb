# Ask Eyeshade to assign an Uphold account to a Publisher.
class PublisherWalletSetter < BaseApiClient
  attr_reader :publisher, :bitcoin_address

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    if !publisher.uphold_access_parameters
      raise "Publisher #{publisher.id} is missing uphold_access_parameters."
    end

    # This raises when response is not 2xx.
    response = connection.put do |request|
      request.body = "{\"provider\": \"uphold.com\", \"parameters\": #{publisher.uphold_access_parameters}, \"verificationId\": \"#{publisher.id}\"}"
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/v2/publishers/#{publisher.brave_publisher_id}/wallet")
    end
  end

  def perform_offline
    Rails.logger.info("PublisherWalletSetter eyeshade offline; only locally updating uphold_access_parameters.")
    true
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end

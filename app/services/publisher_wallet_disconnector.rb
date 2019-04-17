# Ask Eyeshade to disconnect an Uphold account to a Publisher.
class PublisherWalletDisconnector < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    if publisher.uphold_connection.uphold_verified
      raise "Publisher #{publisher.id} has re-verified their Uphold connection, so it should not be disconnected."
    end

    # This raises when response is not 2xx.
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"

      request.body =
          <<~BODY
          {
            "provider": "uphold",
            "parameters": {}
          }
      BODY
      request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
    end

    response

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletDisconnector #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherWalletDisconnector eyeshade offline")
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

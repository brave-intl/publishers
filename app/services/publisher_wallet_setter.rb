# Ask Eyeshade to assign a Publisher a particular bitcoin wallet address.
class PublisherWalletSetter < BaseApiClient
  attr_reader :publisher, :bitcoin_address

  def initialize(bitcoin_address:, publisher:)
    @bitcoin_address = bitcoin_address
    @publisher = publisher
    require "bitcoin"
    if !Bitcoin.valid_address?(@bitcoin_address)
      raise "Address is invalid: #{@bitcoin_address}"
    end
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    params = {
      "bitcoinAddress" => bitcoin_address,
      "verificationId" => publisher.id,
    }
    # This raises when response is not 2xx.
    response = connection.put do |request|
      request.body = JSON.dump(params)
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/v1/publishers/#{publisher.brave_publisher_id}/wallet")
    end
  end

  def perform_offline
    Rails.logger.info("PublisherVerifier eyeshade offline; only locally updating Bitcoin address.")
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

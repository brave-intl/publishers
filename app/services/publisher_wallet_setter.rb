# Ask Eyeshade to assign a Publisher a particular bitcoin wallet address.
class PublisherWalletSetter
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

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
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
end

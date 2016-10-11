# Query pending balance from Eyeshade
class PublisherBalanceGetter
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    # params = {
    #   "currency" => "USD"
    # }
    response = connection.post do |request|
      # request.body = JSON.dump(params)
      request.headers["Authorization"] = api_authorization_header
      request.url("/v1/publishers/#{publisher.brave_publisher_id}/balance")
    end
    response_hash = JSON.parse(response.body)
    # Amount is rounded to the nearest whole dollar.
    # {"amount"=>42, "currency"=>"USD", "satoshis"=>0}
    Balance.new(response_hash["amount"], response_hash["currency"], response_hash["satoshis"])
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

  Balance = Struct.new(:amount, :currency, :satoshis) do
    def to_s
      "#{amount} #{currency}"
    end
  end
end

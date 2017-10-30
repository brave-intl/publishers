require "eyeshade/balance"

# Query pending balance from Eyeshade
class PublisherBalanceGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    response = connection.get do |request|
      # request.body = JSON.dump(params)
      request.headers["Authorization"] = api_authorization_header
      request.url("/v2/publishers/#{publisher.brave_publisher_id}/balance")
    end
    response_hash = JSON.parse(response.body)
    Eyeshade::Balance.new(balance_json: response_hash)
  rescue Faraday::Error => e
    Rails.logger.warn("PublisherBalanceGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherBalanceGetter returning offline stub balance.")
    Eyeshade::Balance.new(
      balance_json: {
        "amount" => "9001.00",
        "currency" => "USD",
        "altcurrency" => "BAT",
        "probi" => "38077497398351695427000",
        "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
        }
      }
    )
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end

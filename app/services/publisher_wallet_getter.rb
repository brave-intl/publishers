require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    response = connection.get do |request|
      if publisher.publication_type == :site
        request.headers["Authorization"] = api_authorization_header
        request.url("/v2/publishers/#{publisher.brave_publisher_id}/wallet")
      elsif publisher.publication_type == :youtube_channel
        request.headers["Authorization"] = api_authorization_header
        request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
      else
        begin
          raise "PublisherWalletGetter can't get wallet for publication_type #{publisher.publication_type.to_s}"
        rescue => e
          require "sentry-raven"
          Raven.capture_exception(e)
        end
        return nil
      end
    end
    response_hash = JSON.parse(response.body)
    Eyeshade::Wallet.new(wallet_json: response_hash)
  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherWalletGetter returning offline stub balance.")
    Eyeshade::Wallet.new(
      wallet_json: {
        "status" => {
            "provider" => "uphold",
            # "action" => "re-authorize"
            # "action" => "authorize"
        },
        "contributions" => {
          "amount" => "9001.00",
          "currency" => "USD",
          "altcurrency" => "BAT",
          "probi" => "38077497398351695427000"
        },
        "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
        },
        "wallet" => {
            "provider" => "uphold",
            "authorized" => true,
            "preferredCurrency" => 'USD',
            "availableCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ]
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

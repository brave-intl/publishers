require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    wallet_response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
    end

    wallet_hash = JSON.parse(wallet_response.body)

    channels_hash = PublisherBalanceGetter.new(publisher: publisher).perform

    Eyeshade::Wallet.new(
      wallet_json: wallet_hash,
      channels_json: channels_hash
    )

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
            "defaultCurrency" => "#{publisher.default_currency}",
            "availableCurrencies" => [ "USD", "EUR", "BTC", "ETH", "BAT" ],
            "possibleCurrencies"=> ["AED", "ARS", "AUD", "BRL", "CAD", "CHF", "CNY", "DKK", "EUR", "GBP", "HKD", "ILS", "INR", "JPY", "KES", "MXN", "NOK", "NZD", "PHP", "PLN", "SEK", "SGD", "USD", "XAG", "XAU", "XPD", "XPT"],
            "scope"=> "cards:read user:read"
        }
      },
      channels_json: PublisherBalanceGetter.new(publisher: publisher).perform_offline
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

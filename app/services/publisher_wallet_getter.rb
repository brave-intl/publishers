require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    # Eyeshade only creates an account for an owner when they connect to Uphold.
    # Until then, the request to get the wallet information for the owner will 404.
    # In that case we use an empty wallet, but still use balances from the balance getter.
    begin
      wallet_response = connection.get do |request|
        request.headers["Authorization"] = api_authorization_header
        request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
      end

      wallet_info = JSON.parse(wallet_response.body)
    rescue Faraday::ResourceNotFound
      wallet_info = {}
    end

    if publisher.channels.verified.present?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform
      return if accounts == :unavailable
    else
      accounts = []
    end

    Eyeshade::Wallet.new(wallet_info: wallet_info,
                         accounts: accounts,
                         transactions: PublisherTransactionsGetter.new(publisher: @publisher).perform)

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherWalletGetter returning offline stub balance.")

    wallet_info = {
        "status" => {
            "provider" => "uphold",
            # "action" => "re-authorize"
            # "action" => "authorize"
        },
        "contributions" => {
          "amount" => "9001.00",
          "currency" => @publisher.default_currency,
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
        # lastSettlement will be ignored in favor of using eyeshade's /transactions endpoint
        "lastSettlement"=>
          {"altcurrency"=>"BAT",
           "currency"=>"USD",
           "probi"=>"405520562799219044167",
           "amount"=>"69.78",
           "timestamp"=>1536361540000},
        "wallet" => {
            "provider" => "uphold",
            "authorized" => true,
            "defaultCurrency" => @publisher.default_currency,
            "availableCurrencies" => [ "USD", "EUR", "BTC", "ETH", "BAT" ],
            "possibleCurrencies"=> ["AED", "ARS", "AUD", "BRL", "CAD", "CHF", "CNY", "DKK", "EUR", "GBP", "HKD", "ILS", "INR", "JPY", "KES", "MXN", "NOK", "NZD", "PHP", "PLN", "SEK", "SGD", "USD", "XAG", "XAU", "XPD", "XPT"],
            "scope"=> "cards:read user:read"
        },
      }

    if publisher.channels.verified.any?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform
    else
      accounts = {}
    end

    Eyeshade::Wallet.new(
      wallet_info: wallet_info,
      accounts: accounts,
      transactions: PublisherTransactionsGetter.new(publisher: @publisher).perform
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

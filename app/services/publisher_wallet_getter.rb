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

    rates = wallet_hash["rates"]
    
    currency = wallet_hash.dig("contributions", "currency") || publisher.default_currency

    if publisher.channels.verified.present?
      channel_balances_response = PublisherBalanceGetter.new(publisher: publisher).perform
      channel_hash = parse_channel_balances_response(channel_balances_response, rates, currency)

      # Replace owner balance with sum of channel balances # TODO: Remove owner balance from the /wallet response
      owner_balance_probi = sum_channel_balances(channel_balances_response) * 1E18
      wallet_hash["contributions"]["probi"] = owner_balance_probi if wallet_hash.dig("contributions","probi")
    else
      channel_hash = {}
    end

    Eyeshade::Wallet.new(wallet_json: wallet_hash,channel_json: channel_hash)

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherWalletGetter returning offline stub balance.")

    wallet_hash = {
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
            "defaultCurrency" => "USD",
            "availableCurrencies" => [ "USD", "EUR", "BTC", "ETH", "BAT" ],
            "possibleCurrencies"=> ["AED", "ARS", "AUD", "BRL", "CAD", "CHF", "CNY", "DKK", "EUR", "GBP", "HKD", "ILS", "INR", "JPY", "KES", "MXN", "NOK", "NZD", "PHP", "PLN", "SEK", "SGD", "USD", "XAG", "XAU", "XPD", "XPT"],
            "scope"=> "cards:read user:read"
        }
      }

    channel_balances_response = PublisherBalanceGetter.new(publisher: publisher).perform
    channel_hash = parse_channel_balances_response(channel_balances_response, wallet_hash["rates"], wallet_hash["contributions"]["currency"])

    # Replace owner balance with sum of channel balance # TODO: Remove owner balance from the /wallet response
    owner_balance_probi = sum_channel_balances(channel_balances_response) * 1E18
    wallet_hash["contributions"]["probi"] = owner_balance_probi if wallet_hash.dig("contributions","probi")

    Eyeshade::Wallet.new(
      wallet_json: wallet_hash,
      channel_json: channel_hash
    )
  end

  private

  def parse_channel_balances_response(channel_balances_response, rates, default_currency)
    channel_hash = {}
    channel_balances_response.each do |channel_balance|
      channel_id = channel_balance["account_id"]
      channel_bat = channel_balance["balance"].to_d
      channel_probi = channel_bat * 1E18

      channel_hash[channel_id] = {
        "rates" => rates,
        "altcurrency" => "BAT",
        "probi" => channel_probi,
        "amount" => channel_bat,
        "currency" => default_currency
      }
    end

    channel_hash
  end

  def sum_channel_balances(channel_balances_response)
    sum = 0
    channel_balances_response.each do |channel_balance|
      next if channel_balance["account_type"] == "owner" # Do not sum owner accounts
      sum += channel_balance["balance"].to_d
    end
    sum
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end

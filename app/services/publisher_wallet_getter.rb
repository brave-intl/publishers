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

    if publisher.channels.verified.present?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform

      # Override owner balance with transaction table value
      if wallet_hash.dig("contributions", "probi")
        owner_balance = owner_balance_bat(accounts)
        wallet_hash["contributions"]["probi"] = owner_balance_bat(accounts).to_d * 1E18
        wallet_hash["contributions"]["amount"] = owner_balance 
      end

      # Convert accounts into Eyeshade::Wallet format
      channel_hash = parse_accounts(accounts, wallet_hash)
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

    if publisher.channels.verified.any?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform

      # Override owner balance with transaction table value
      if wallet_hash.dig("contributions", "probi")
        owner_balance = owner_balance_bat(accounts)
        wallet_hash["contributions"]["probi"] = owner_balance_bat(accounts).to_d * 1E18
        wallet_hash["contributions"]["amount"] = owner_balance 
      end

      # Convert accounts into Eyeshade::Wallet format
      channel_hash = parse_accounts(accounts, wallet_hash)
    else
      channel_hash = {}
    end

    Eyeshade::Wallet.new(
      wallet_json: wallet_hash,
      channel_json: channel_hash
    )
  end

  private

  # Converts the account_balances returned in the PublisherBalanceGetter
  # into a format suitable for the Eyeshade::Wallet
  def parse_accounts(accounts, wallet_hash)
    rates = wallet_hash["rates"]
    currency = wallet_hash.dig("contributions", "currency") || publisher.default_currency

    channel_hash = {}

    accounts.each do |account|
      next if account["account_type"] == "owner"

      channel_identifier = account["account_id"]
      channel_balance = account["balance"]

      channel_hash[channel_identifier] = {
        "rates" => rates,
        "altcurrency" => "BAT",
        "probi" => channel_balance.to_d * 1E18,
        "amount" => channel_balance,
        "currency" => currency
      }
    end

    channel_hash
  end

  def owner_balance_bat(accounts)
    owner_balance = nil

    accounts.each do |account|
      next unless account["account_type"] == "owner"
      owner_balance = account["balance"]
    end

    raise if owner_balance == nil # Owner balance should always exist
    owner_balance
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end

require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    
    # Get wallet information
    begin
      # Eyeshade only creates an account for an owner when they connect to Uphold.
      # Until then, the request to get the wallet information for the owner will 404.
      # In that case we use an empty wallet, but still use balances from the balance getter.
      wallet_response = connection.get do |request|
        request.headers["Authorization"] = api_authorization_header
        request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
      end

      wallet_hash = JSON.parse(wallet_response.body)
    rescue Faraday::ResourceNotFound
      wallet_hash = {}
    end

    # Get account balances
    if publisher.channels.verified.present?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform
      return if accounts == :unavailable

      # Always override owner balance with transaction table value
      contributions = {
        "probi" => total_balance_bat(accounts) * BigDecimal.new('1.0e18'),
        "amount" => total_balance_bat(accounts) 
      }

      wallet_hash["contributions"] = contributions

      # Convert accounts into Eyeshade::Wallet format
      channel_hash = parse_accounts(accounts, wallet_hash)
    else
      channel_hash = {}
    end

    # Get last settlement balance from transactions endpoint
    last_settlement_balance = last_settlement_balance(PublisherTransactionsGetter.new(publisher: @publisher).perform)
    unless last_settlement_balance.empty? || (last_settlement_balance["amount"].to_i == 0)
      wallet_hash["lastSettlement"] = last_settlement_balance
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
        "lastSettlement"=> last_settlement_balance(PublisherTransactionsGetter.new(publisher: @publisher).perform_offline),
          # {"altcurrency"=>"BAT",
          #  "currency"=>"USD",
          #  "probi"=>"405520562799219044167",
          #  "amount"=>"69.78",
          #  "timestamp"=>1536361540000},
        "wallet" => {
            "provider" => "uphold",
            "authorized" => true,
            "defaultCurrency" => "USD",
            "availableCurrencies" => [ "USD", "EUR", "BTC", "ETH", "BAT" ],
            "possibleCurrencies"=> ["AED", "ARS", "AUD", "BRL", "CAD", "CHF", "CNY", "DKK", "EUR", "GBP", "HKD", "ILS", "INR", "JPY", "KES", "MXN", "NOK", "NZD", "PHP", "PLN", "SEK", "SGD", "USD", "XAG", "XAU", "XPD", "XPT"],
            "scope"=> "cards:read user:read"
        },
      }

    if publisher.channels.verified.any?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform

      # Override owner balance with transaction table value
      if wallet_hash.dig("contributions", "probi")
        wallet_hash["contributions"]["probi"] = total_balance_bat(accounts).to_d * BigDecimal.new('1.0e18')
        wallet_hash["contributions"]["amount"] = total_balance_bat(accounts) 
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
      channel_identifier = account["account_id"]
      channel_balance = account["balance"]

      channel_hash[channel_identifier] = {
        "rates" => rates,
        "altcurrency" => "BAT",
        "probi" => channel_balance.to_d * BigDecimal.new('1.0e18'),
        "amount" => channel_balance,
        "currency" => currency
      }
    end

    channel_hash
  end

  def total_balance_bat(accounts)
    accounts.map {|account| account["balance"].to_d }.reduce(0, :+)
  end

  def last_settlement_balance(transactions)
    return {} if transactions == []

    # Find most recent settlement transaction
    last_settlement_date = transactions.select { |transaction|
      transaction["settlement_amount"].present?
    }.last["created_at"].to_date # Eyeshade returns transactions ordered_by created_at

    # Find all settlement transactions that occur within the same month as the last settlement timestamp
    last_settlement_transactions = transactions.select { |transaction|
      transaction["created_at"].to_date.at_beginning_of_month == last_settlement_date.at_beginning_of_month &&
      transaction["settlement_amount"].present?
    }

    last_settlement_currency = last_settlement_transactions&.first["settlement_currency"] || nil

    last_settlement_probi = last_settlement_transactions.map { |transaction|
      transaction["settlement_amount"].to_d
    }.reduce(:+).to_d
    
    {
      "altcurrency" => "BAT",
      "currency" => last_settlement_currency,
      "probi" => (last_settlement_probi * BigDecimal.new('1.0e18')),
      "amount" => last_settlement_probi,
      "timestamp" => last_settlement_date.to_time.to_i
    }
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end

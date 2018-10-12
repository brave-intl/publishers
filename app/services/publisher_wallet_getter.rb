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
    # TODO: Remove else condition when transaction table is stable
    if should_use_transaction_table?
      if publisher.channels.verified.present?
        accounts = PublisherBalanceGetter.new(publisher: publisher).perform
        return if accounts == :unavailable

        # Override owner balance with transaction table value
        if wallet_hash.dig("contributions", "probi")
          wallet_hash["contributions"]["probi"]  = total_balance_bat(accounts) * BigDecimal.new('1.0e18')
          wallet_hash["contributions"]["amount"] = total_balance_bat(accounts) 
        end

        # Convert accounts into Eyeshade::Wallet format
        channel_hash = parse_accounts(accounts, wallet_hash)
      else
        channel_hash = {}
      end
    else
      channel_responses = {}
      publisher.channels.verified.each do |channel|
        identifier =  channel.details.channel_identifier
        channel_responses[identifier] = connection.get do |request|
          request.headers["Authorization"] = api_authorization_header
          request.url("/v2/publishers/#{URI.escape(identifier)}/balance")
        end
      end

      channel_hash = {}
      channel_responses.each do |identifier, response|
        channel_hash[identifier] = JSON.parse(response.body)
      end
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
        "lastSettlement"=>
          {"altcurrency"=>"BAT",
           "currency"=>"USD",
           "probi"=>"405520562799219044167",
           "amount"=>"69.78",
           "timestamp"=>1536361540000},
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

  def should_use_transaction_table?
    Rails.application.secrets[:should_use_transaction_table]
  end

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

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end

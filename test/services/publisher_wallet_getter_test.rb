require "test_helper"

class PublisherWalletGetterTest < ActiveJob::TestCase
  include EyeshadeHelper

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "when offline returns a wallet with fake data" do
    Rails.application.secrets[:api_eyeshade_offline] = true

    publisher = publishers(:verified)
    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
  end

  test "when online returns a wallet" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:google_verified)
    publisher.channels.delete_all
    wallet = {
      "wallet": {
        "provider": "uphold",
        "authorized": true,
        "defaultCurrency": "USD",
        "availableCurrencies": [ "EUR", "BTC", "ETH" ],
        "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
        "scope": ["cards:write"]
      }
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
    assert_equal "USD", result.default_currency
  end

  test "when online returns a wallet with channel data" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:completed)
    wallet = {
      "wallet": {
        "provider": "uphold",
        "authorized": true,
        "defaultCurrency": "USD",
        "availableCurrencies": [ "EUR", "BTC", "ETH" ],
        "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
        "scope": ["cards:write"]
      }
    }

    balances = [
      {
        "account_id" => "completed.org",
        "balance" => "25.00",
        "account_type" => "channel"
      },
      {
        "accont_type" => "channel",
        "account_id" => "youtube#channeldef456",
        "balance" => "10014"
      }
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)

    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
    assert_equal "USD", result.default_currency
    assert_equal "23.75", result.channel_balances["completed.org"].amount_bat.to_s
  end

  test "when online only returns channel balances for verified channels and owner" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    # Has one verified, and one unverified channel
    publisher = publishers(:partially_completed)
    wallet = {
      "wallet": {
        "provider": "uphold",
        "authorized": true,
        "defaultCurrency": "USD",
        "availableCurrencies": [ "EUR", "BTC", "ETH" ],
        "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
        "scope": ["cards:write"]
      }
    }
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)
    result = PublisherWalletGetter.new(publisher: publisher).perform
    # Ensure the wallet getter only returns channel balance for the verified channel
    assert result.channel_balances.count == 1
  end

  test "uses the PublisherBalanceGetter to populate pending balances" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)

    wallet = {
      "rates"=> {
        "BTC"=>3.138e-05,
        "XAU"=>0.00019228366919698587
      }
    }

    balances = [
      {
        "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
        "account_type" => "owner",
        "balance" => "20.00"
      },
      {
        "account_id" => "uphold_connected.org",
        "account_type" => "channel",
        "balance" => "20.00"
      },
      {
        "account_id" => "twitch#channel:ucTw",
        "account_type" => "channel",
        "balance" => "20.00"
      },
      {
        "account_id" => "twitter#channel:def456",
        "account_type" => "channel",
        "balance" => "20.00"
      }
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)
    wallet = PublisherWalletGetter.new(publisher: publisher).perform

    channel_amount_after_fees = (20 - 20 * Rails.application.secrets[:fee_rate])
    owner_amounts_after_fees = 20
    overall_amount_after_fees = (channel_amount_after_fees * 3 + owner_amounts_after_fees).to_s
    assert_equal wallet.overall_balance.amount_bat.to_s, overall_amount_after_fees
    assert_equal wallet.overall_balance.amount_probi,  (overall_amount_after_fees.to_d * BigDecimal.new('1.0e18')).to_i
  end

  test "uses the PublisherTransactionsGetter to get last settlement information" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)

    wallet = {
      "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
      },
    }
    transactions = PublisherTransactionsGetter.new(publisher: publisher).perform_offline
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, transactions: transactions)

    wallet = PublisherWalletGetter.new(publisher: publisher).perform
    last_settlement_balance = wallet.last_settlement_balance

    assert_equal last_settlement_balance.amount_bat.to_s, "226.86"
    assert_equal last_settlement_balance.amount_settlement_currency.to_s, "0.18042880927910732262"
    assert_equal last_settlement_balance.settlement_currency, "ETH"
  end

  test "gets a wallet with all empty eyeshade reponses" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)
    
    stub_all_eyeshade_wallet_responses(publisher: publisher)
    
    wallet = PublisherWalletGetter.new(publisher: publisher).perform
    assert wallet.is_a?(Eyeshade::Wallet)
  end
end

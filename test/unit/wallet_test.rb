require "test_helper"
require "eyeshade/wallet"

class WalletTest < ActiveSupport::TestCase

  test_wallet = Eyeshade::Wallet.new(
      wallet_json: {
        "rates" => {
            "BTC" => 0.00005418424016883016,
            "ETH" => 0.000795331082073117,
            "USD" => 0.2363863335301452,
            "EUR" => 0.20187818378874756,
            "GBP" => 0.1799810085548496
        },
        "status" => {
            "provider" => "uphold",
            "action" => "re-authorize"
        },
        "wallet" => {
            "provider" => "uphold",
            "authorized" => true,
            "defaultCurrency" => 'USD',
            "availableCurrencies" => [ 'USD', 'EUR', 'BAT' ],
            "possibleCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ],
            "scope" => 'cards:write'
        }
      },
      channels_json: [
        {
          "account" => "youtube#channel:123abc",
          "balance" => "70.00"
        },
        {
          "account" => "brave.com",
          "balance" => "30.00"
        }
      ]
  )

  empty_wallet = Eyeshade::Wallet.new(wallet_json: {}, channels_json: {})

  test "supports action" do
    assert_equal('re-authorize', test_wallet.action)
  end

  test "converts balance" do
    test_balance = test_wallet.owner_balance
    usd = test_wallet.convert_balance(test_balance, 'USD')

    assert usd == ('%.2f' % (0.2363863335301452 * 100))
  end

  test "handles initialization with empty wallet details" do
    assert empty_wallet.available_currencies.is_a?(Array)
    assert empty_wallet.possible_currencies.is_a?(Array)
  end

  test "parses wallet status and details" do
    assert_equal "re-authorize", test_wallet.action
    assert_equal true, test_wallet.authorized?
    assert_equal "uphold", test_wallet.provider
    assert_equal 'cards:write', test_wallet.scope
    assert_equal "USD", test_wallet.default_currency
    assert_equal [ 'USD', 'EUR', 'BAT' ], test_wallet.available_currencies
    assert_equal [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ], test_wallet.possible_currencies
  end

  test "currency_is_possible_but_not_available? checks available and possible currencies" do
    assert test_wallet.currency_is_possible_but_not_available?('ETH')
    refute test_wallet.currency_is_possible_but_not_available?('USD')
    refute test_wallet.currency_is_possible_but_not_available?('FAKE')
  end

  test "converts channels_json to an hash format with channel ids as keys" do
    channel_balances = test_wallet.channel_balances
    assert channel_balances.is_a?(Hash)
    assert_equal channel_balances.length, 2

    assert_equal channel_balances["brave.com"], "30.00"
    assert_equal channel_balances["youtube#channel:123abc"], "70.00"
  end

  test "channel balances sum to owner balance" do
    owner_balance = test_wallet.owner_balance

    assert_equal owner_balance, 100
  end

  test "raises error if converting to currency with unknown rates" do
    assert_raises do
      test_wallet.convert_balance("200" , "LOL")
    end
  end

  test "convert_balance returns string with two decimal places" do
    assert_equal "100.00", test_wallet.convert_balance(100, "BAT")
  end

  test "converted balance is unchanged if default currency is BAT" do
    assert_equal "100.00", test_wallet.convert_balance("100.00", "BAT")
  end

  test "converted balance is unchanged if default currency is not set" do
    assert_equal "100.00", test_wallet.convert_balance("100.00", nil)
  end
end

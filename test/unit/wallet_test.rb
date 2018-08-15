require "test_helper"
require "eyeshade/wallet"

class WalletTest < ActiveSupport::TestCase

  test_wallet = Eyeshade::Wallet.new(
      wallet_json: {
        "contributions" => {
            "amount" => "5.80",
            "currency" => "USD",
            "altcurrency" => "BAT",
            "probi" => "25000000000000000000"
        },
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
      channel_json: {}
  )

  empty_wallet = Eyeshade::Wallet.new(wallet_json: {}, channel_json: {})

  test "supports action" do
    assert_equal('re-authorize', test_wallet.action)
  end

  test "translates contributions to a Balance" do
    test_balance = test_wallet.contribution_balance
    assert(test_balance.is_a?(Eyeshade::Balance))
    usd = test_balance.convert_to('USD')
    assert usd == 0.2363863335301452 * 25.0
    assert usd.is_a?(BigDecimal)
  end

  test "handles initialization with empty wallet details" do
    assert empty_wallet.available_currencies.is_a?(Array)
    assert empty_wallet.possible_currencies.is_a?(Array)
    assert empty_wallet.contribution_balance.is_a?(Eyeshade::Balance)
    assert empty_wallet.address.is_a?(String)
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
end

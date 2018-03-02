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
            "preferredCurrency" => 'USD',
            "availableCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ]
        }
      },
      channel_json: {}
  )

  empty_wallet = Eyeshade::Wallet.new(wallet_json: {}, channel_json: {})

  test "supports status" do
    assert(test_wallet.status)
    assert_equal('re-authorize', test_wallet.status['action'])
  end

  test "translates contributions to a Balance" do
    test_balance = test_wallet.contribution_balance
    assert(test_balance.is_a?(Eyeshade::Balance))
    usd = test_balance.convert_to('USD')
    assert usd == 0.2363863335301452 * 25.0
    assert usd.is_a?(BigDecimal)
  end

  test "handles initialization with empty wallet details" do
    assert empty_wallet.status.is_a?(Hash)
    assert empty_wallet.contribution_balance.is_a?(Eyeshade::Balance)
  end

  test "supports wallet details" do
    assert(test_wallet.wallet_details.is_a?(Hash))
  end

  test "supports wallet details preferred currency" do
    assert_equal('USD', test_wallet.wallet_details['preferredCurrency'])
  end

  test "supports wallet details available currencies" do
    assert(test_wallet.wallet_details['availableCurrencies'].is_a?(Array))
    assert_equal('USD', test_wallet.wallet_details['availableCurrencies'][0])
    assert_equal('EUR', test_wallet.wallet_details['availableCurrencies'][1])
  end
end

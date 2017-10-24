require "test_helper"
require "eyeshade/balance"

class BalanceTest < ActiveSupport::TestCase

  test_balance = Eyeshade::Balance.new(
      balance_json: {
          "amount" => "5.80",
          "currency" => "USD",
          "altcurrency" => "BAT",
          "probi" => "25000000000000000000",
          "rates" => {
              "BTC" => 0.00005418424016883016,
              "ETH" => 0.000795331082073117,
              "USD" => 0.2363863335301452,
              "EUR" => 0.20187818378874756,
              "GBP" => 0.1799810085548496
          }
      }
  )

  test "supports probi" do
    assert(test_balance.probi == 25000000000000000000 )
  end

  test "converts to BAT" do
    bat = test_balance.BAT
    assert bat == 25.0
    assert bat.is_a?(BigDecimal)
  end

  test "converts BAT to currency" do
    usd = test_balance.convert_to('USD')
    assert usd == 0.2363863335301452 * 25.0
    assert usd.is_a?(BigDecimal)
  end

  test "accepts lowercase currencies" do
    usd = test_balance.convert_to('usd')
    assert usd == 0.2363863335301452 * 25.0
    assert usd.is_a?(BigDecimal)
  end

  test "converts BAT to currency raises exception if conversion rate is not found" do
    assert_raises do
      test_balance.convert_to('FOO')
    end
  end

end

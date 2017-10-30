require "test_helper"
require "webmock/minitest"

class PublisherBalanceGetterTest < ActiveJob::TestCase
  
  test "when offline gets a balance" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)

      balance = PublisherBalanceGetter.new(publisher: publisher).perform

      assert_equal 38077497398351695427000, balance.probi
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "when online gets a balance" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      balance_json = {
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

      stub_request(:get, /v2\/publishers\/verified.org\/balance/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: balance_json.to_json, headers: {})

      publisher = publishers(:verified)
      balance = PublisherBalanceGetter.new(publisher: publisher).perform

      assert_equal 25000000000000000000, balance.probi
      usd = balance.convert_to('USD')
      assert usd == 0.2363863335301452 * 25.0
      assert usd.is_a?(BigDecimal)
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end
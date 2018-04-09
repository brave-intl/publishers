require "test_helper"
require "webmock/minitest"

class PublisherDefaultCurrencySetterTest < ActiveJob::TestCase
  test "when offline returns true" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)
      result = PublisherDefaultCurrencySetter.new(publisher: publisher).perform

      assert_equal true, result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online returns the response when the default currency can be set" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.default_currency = 'USD'

      stub_request(:patch, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
          with(headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization'=>"Bearer #{Rails.application.secrets[:api_eyeshade_key]}",
                         'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
               body:
                 <<~BODY
                 {
                   "defaultCurrency": "USD" 
                 }
                 BODY
          ).
          to_return(status: 204, headers: {})

      result = PublisherDefaultCurrencySetter.new(publisher: publisher).perform
      assert_equal 204, result.status
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end
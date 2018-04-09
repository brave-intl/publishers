require "test_helper"
require "webmock/minitest"

class UploadDefaultCurrencyJobTest < ActiveJob::TestCase
  test "sends default currency to eyeshade" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.default_currency = 'USD'
      publisher.save!

      stub_request(:patch, /v1\/owners\/#{publisher.owner_identifier}\/wallet/).
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
        )

      UploadDefaultCurrencyJob.perform_now(publisher_id: publisher.id)

      publisher.reload
      assert_equal 'USD', publisher.default_currency
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end

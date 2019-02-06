require "test_helper"
require "webmock/minitest"

class CardCreationServiceTest < ActiveJob::TestCase
  test "when offline returns true" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)
      result = UpholdServices::CardCreationService.new(publisher: publisher, currency_code: "BAT").perform

      assert_equal true, result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "request has correct format" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false
      publisher = publishers(:verified)

      stub_request(:post, /v3\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet\/card/).
          with(
               headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization'=>"Bearer #{Rails.application.secrets[:api_eyeshade_key]}",
                         'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
               body: {
                "currency": "BAT",
                "label": "Brave Rewards"
               }.to_json
          ).
          to_return(status: 200, headers: {})

      result = UpholdServices::CardCreationService.new(publisher: publisher, currency_code: "BAT").perform
      assert_equal 200, result.status

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end

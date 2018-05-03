require "test_helper"
require "webmock/minitest"

class PublisherWalletDisconnectorTest < ActiveJob::TestCase
  test "when offline returns true" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)
      result = PublisherWalletDisconnector.new(publisher: publisher).perform

      assert_equal true, result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online returns response when the wallet can be set" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_verified = false

      stub_request(:put, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
          with(headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization'=>"Bearer #{Rails.application.secrets[:api_eyeshade_key]}",
                         'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
               body:
                   <<~BODY
                {
                  "provider": "uphold", 
                  "parameters": {}
                }
          BODY
          ).
          to_return(status: 200, headers: {})

      result = PublisherWalletDisconnector.new(publisher: publisher).perform
      assert_equal 200, result.status
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "raises if uphold has been reverified" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_verified = true

      assert_raises("Publisher #{publisher.id} has re-verified their Uphold connection, so it should not be disconnected.") do
        PublisherWalletDisconnector.new(publisher: publisher).perform
      end
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end
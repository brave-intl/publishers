require "test_helper"
require "webmock/minitest"

class PublisherWalletSetterTest < ActiveJob::TestCase
  test "when offline returns true" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)
      result = PublisherWalletSetter.new(publisher: publisher).perform

      assert_equal true, result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online, for site publishers, returns true when the wallet can be set" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_access_parameters = "{\"foo\":\"bar\"}"
      wallet = "{\"wallet\":\"abc123\"}"

      stub_request(:put, /v2\/publishers\/verified\.org\/wallet/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
               body:
                 <<~BODY
                  {
                    "provider": "uphold", 
                    "parameters": {\"foo\":\"bar\",\"server\":\"https://uphold-api.example.com\"}, 
                    "verificationId": "#{publisher.id}"
                  }
                BODY
          ).
          to_return(status: 200, body: wallet, headers: {})

      result = PublisherWalletSetter.new(publisher: publisher).perform
      assert_equal 200, result.status
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online, for YT publishers, returns true when the wallet can be set" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:google_verified)
      publisher.uphold_access_parameters = "{\"foo\":\"bar\"}"
      wallet = "{\"wallet\":\"abc123\"}"

      stub_request(:put, /v1\/owners\/oauth%23google:abc123\/wallet/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
             body:
               <<~BODY
                {
                  "provider": "uphold", 
                  "parameters": {\"foo\":\"bar\",\"server\":\"https://uphold-api.example.com\"}
                }
              BODY
        ).
        to_return(status: 200, body: wallet, headers: {})

      result = PublisherWalletSetter.new(publisher: publisher).perform
      assert_equal 200, result.status
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end
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

  test "when online returns true when the wallet can be set" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_access_parameters = "{\"foo\":\"bar\"}"
      wallet = "{\"wallet\":\"abc123\"}"

      stub_request(:put, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
          with(body: "{\n  \"provider\": \"uphold\",\n  \"parameters\": {\"foo\":\"bar\",\"server\":\"https://uphold-api.example.com\"}\n}\n").
          to_return(status: 200, body: wallet, headers: {})

      result = PublisherWalletSetter.new(publisher: publisher).perform
      assert_equal 200, result.status
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end

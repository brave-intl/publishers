require "test_helper"
require "webmock/minitest"

class PublisherWalletGetterTest < ActiveJob::TestCase
  test "when offline returns a wallet with fake data" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)
      result = PublisherWalletGetter.new(publisher: publisher).perform

      assert result.kind_of?(Eyeshade::Wallet)

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online, for site publishers, returns a wallet" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      wallet = "{\"wallet\":\"abc123\"}"

      stub_request(:get, /v2\/publishers\/verified\.org\/wallet/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: wallet, headers: {})

      result = PublisherWalletGetter.new(publisher: publisher).perform

      assert result.kind_of?(Eyeshade::Wallet)
      assert_equal JSON.parse(wallet), result.wallet_json
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online, for YT publishers, returns a wallet" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:google_verified)
      wallet = "{\"wallet\":\"abc123\"}"

      stub_request(:get, /v1\/owners\/oauth%23google:abc123\/wallet/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: wallet, headers: {})

      result = PublisherWalletGetter.new(publisher: publisher).perform

      assert result.kind_of?(Eyeshade::Wallet)
      assert_equal JSON.parse(wallet), result.wallet_json
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end
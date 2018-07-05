require "test_helper"

class PublisherWalletGetterTest < ActiveJob::TestCase

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "when offline returns a wallet with fake data" do
    Rails.application.secrets[:api_eyeshade_offline] = true

    publisher = publishers(:verified)
    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
  end

  test "when online returns a wallet" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:google_verified)
    publisher.channels.delete_all
    wallet = {
      "wallet": {
        "provider": "uphold",
        "authorized": true,
        "defaultCurrency": "USD",
        "availableCurrencies": [ "EUR", "BTC", "ETH" ],
        "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
        "scope": ["cards:write"]
      }
    }.to_json

    stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: wallet, headers: {})

    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
    assert_equal "USD", result.default_currency
  end

  test "when online returns a wallet with channel data" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:completed)
    wallet = {
      "wallet": {
        "provider": "uphold",
        "authorized": true,
        "defaultCurrency": "USD",
        "availableCurrencies": [ "EUR", "BTC", "ETH" ],
        "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
        "scope": ["cards:write"]
      }
    }.to_json

    stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: wallet, headers: {})

    publisher.channels.each do |channel|
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
      }.to_json

      stub_request(:get, %r{v2/publishers/#{URI.escape(channel.details.channel_identifier)}/balance}).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: balance_json, headers: {})
    end

    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
    assert_equal "USD", result.default_currency

    assert_equal(
      25.0,
      result.channel_balances["completed.org"].BAT
    )
  end

  test "when online only returns channel balances for verified channels" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    # Has one verified, and one unverified channel
    publisher = publishers(:partially_completed)

    wallet = {
      "wallet": {
        "provider": "uphold",
        "authorized": true,
        "defaultCurrency": "USD",
        "availableCurrencies": [ "EUR", "BTC", "ETH" ],
        "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
        "scope": ["cards:write"]
      }
    }.to_json

    stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: wallet, headers: {})

    publisher.channels.each do |channel|
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
      }.to_json

      stub_request(:get, %r{v2/publishers/#{URI.escape(channel.details.channel_identifier)}/balance}).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: balance_json, headers: {})
    end
    result = PublisherWalletGetter.new(publisher: publisher).perform

    # Ensure the wallet getter only returns channel balance for the verified channel
    assert result.channel_balances.count == 1
  end
end

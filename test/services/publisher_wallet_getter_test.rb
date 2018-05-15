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
    wallet = "{\"wallet\":\"abc123\"}"

    stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: wallet, headers: {})

    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
    assert_equal JSON.parse(wallet), result.wallet_json
  end

  test "when online returns a wallet with channel data" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:completed)
    wallet = "{\"wallet\":\"abc123\"}"

    stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: wallet, headers: {})

    publisher.channels.each do |channel|
      stub_request(:get, %r{v2/publishers/#{URI.escape(channel.details.channel_identifier)}/balance}).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: '{}', headers: {})
    end

    result = PublisherWalletGetter.new(publisher: publisher).perform

    assert result.kind_of?(Eyeshade::Wallet)
    assert_equal JSON.parse(wallet), result.wallet_json

    assert_equal(
      publisher.channels.inject({}) { |t,i| t[i.details.channel_identifier] = {}; t },
      result.channel_json
    )
  end

end

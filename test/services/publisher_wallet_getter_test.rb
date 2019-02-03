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

  describe "when online" do
    before do
      Rails.application.secrets[:api_eyeshade_offline] = false
    end
    let(:eyeshade_response) {
      {
        "wallet": {
          "provider": "uphold",
          "authorized": true,
          "isMember": true,
          "status": "ok",
          "defaultCurrency": "USD",
          "availableCurrencies": [ "EUR", "BTC", "ETH" ],
          "possibleCurrencies": [ "USD", "EUR", "BTC", "ETH", "BAT" ],
          "scope": ["cards:write"]
        },
        "rates": {
          "BTC": 3.138e-05,
          "XAU": 0.00019228366919698587
        },
        "contributions": {
          "amount": "5.71",
          "currency": "USD",
          "altcurrency": "BAT",
          "probi": "24881568585439183646"
        },
        "status": {
          "provider": "uphold"
        }
      }
    }

    describe "uphold states" do
      test "verified if authorized and isMember" do
        eyeshade_response[:wallet][:authorized] = true
        eyeshade_response[:wallet][:isMember] = true
        eyeshade_response[:wallet][:status] = "ok"
        publisher = publishers(:uphold_connected)
        publisher.channels.delete_all
        stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: eyeshade_response.to_json, headers: {})
        PublisherWalletGetter.new(publisher: publisher).perform
        assert_equal Publisher::UpholdAccountState::VERIFIED, publisher.uphold_status
      end

      test "not a member yet ok" do
        eyeshade_response[:wallet][:authorized] = true
        eyeshade_response[:wallet][:isMember] = false
        eyeshade_response[:wallet][:status] = "ok"
        publisher = publishers(:uphold_connected)
        publisher.channels.delete_all
        stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: eyeshade_response.to_json, headers: {})
        assert_equal Publisher::UpholdAccountState::RESTRICTED, publisher.uphold_status
      end

      test "unconnected" do
        eyeshade_response.delete(:wallet)
        publisher = publishers(:verified)
        publisher.channels.delete_all
        stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: eyeshade_response.to_json, headers: {})
        assert_equal Publisher::UpholdAccountState::UNCONNECTED, publisher.uphold_status
      end

      test "has an action" do
        publisher = publishers(:uphold_connected)
        publisher.channels.delete_all
        ["re-authorize", "authorize"].each do |action|
          eyeshade_response[:status][:action] = action
          stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
            with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
            to_return(status: 200, body: eyeshade_response.to_json, headers: {})
          PublisherWalletGetter.new(publisher: publisher).perform
          assert_equal Publisher::UpholdAccountState::REAUTHORIZATION_NEEDED, publisher.uphold_status
        end
      end
    end

    test "when online returns a wallet" do
      publisher = publishers(:google_verified)
      publisher.channels.delete_all

      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: eyeshade_response.to_json, headers: {})

      result = PublisherWalletGetter.new(publisher: publisher).perform

      assert result.kind_of?(Eyeshade::Wallet)
      assert_equal "USD", result.default_currency
    end

    test "when online returns a wallet with channel data" do
      publisher = publishers(:completed)

      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: eyeshade_response.to_json, headers: {})

      # stub balance respose
      channel_balances_response = [
        {
          "account_id" => "completed.org",
          "balance" => "25.00"
        },
        {
          "account_id" => "youtube#channeldef456",
          "balance" => "10014"
        }
      ]

      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=publishers%23uuid:4b296ba7-e725-5736-b402-50f4d15b1ac7&account=completed.org").
        to_return(status: 200, body: channel_balances_response.to_json)

      result = PublisherWalletGetter.new(publisher: publisher).perform

      assert result.kind_of?(Eyeshade::Wallet)
      assert_equal "USD", result.default_currency

      assert_equal(
        25.0,
        result.channel_balances["completed.org"].BAT
      )
    end

    test "when online only returns channel balances for verified channels and owner" do
      # Has one verified, and one unverified channel
      publisher = publishers(:partially_completed)

      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: eyeshade_response.to_json, headers: {})

      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=publishers%23uuid:94dba753-de7e-5424-99ba-db53953a7939&account=partially-completed-verified.org").
        to_return(status: 200, body: [].to_json)

      result = PublisherWalletGetter.new(publisher: publisher).perform

      # Ensure the wallet getter only returns channel balance for the verified channel and owner
      assert result.channel_balances.count == 2
    end

    test "overall balance is sum of channel and owner accounts" do
      publisher = publishers(:uphold_connected)

      # Stub /wallet response

      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: eyeshade_response.to_json, headers: {})

      # Stub /balances response
      balance_response = [
        {
          "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
          "account_type" => "owner",
          "balance" => "20.00"
        },
        {
          "account_id" => "uphold_connected.org",
          "account_type" => "channel",
          "balance" => "20.00"
        },
        {
          "account_id" => "twitch#channel:ucTw",
          "account_type" => "channel",
          "balance" => "20.00"
        },
        {
          "account_id" => "twitter#channel:def456",
          "account_type" => "channel",
          "balance" => "20.00"
        }
      ].to_json

      # stub balances response
      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
        to_return(status: 200, body: balance_response)

      wallet = PublisherWalletGetter.new(publisher: publisher).perform

      assert_equal wallet.contribution_balance.amount, 80
      assert_equal wallet.contribution_balance.probi,  80 * BigDecimal.new('1.0e18')
    end
  end
end

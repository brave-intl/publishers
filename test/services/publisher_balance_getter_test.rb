require "test_helper"

class PublisherBalanceGetterTest < ActiveJob::TestCase

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "fills in empty balances only for channels that eyeshade does not return balance info" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)

    # Only include owner account in response
    stubbed_response_body = [{
      "account_id" => "#{publisher.owner_identifier}",
      "account_type" => "owner",
      "balance" => "900"
    }]

    # stub empty response is returned by eyeshade for only one channel
    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
      to_return(status: 200, body: stubbed_response_body.to_json)
      
    accounts = PublisherBalanceGetter.new(publisher: publisher).perform
    assert accounts.length == 4

    account_ids = accounts.map { |account| account["account_id"] }
    publisher.channels.verified.each do |verified_channel|
      assert account_ids.include?(verified_channel.details.channel_identifier)
    end
  end

  test "fills in empty owner balance if not included in eyeshade response" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)

    # Owner balance not included in response
    stubbed_response_body = publisher.channels.verified.map do |channel|
      {
        "account_id" => "#{channel.details.channel_identifier}",
        "account_type" => "channel",
        "balance" => "900"
      }
    end

    # stub empty response is returned by eyeshade for only one channel
    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
      to_return(status: 200, body: stubbed_response_body.to_json)
      
    accounts = PublisherBalanceGetter.new(publisher: publisher).perform

    assert stubbed_response_body.length == 3
    assert accounts.length == 4

    owner_account = nil
    accounts.each do |account|
      next if account["account_type"] == "channel"
      owner_account = account
    end

    assert_not_nil owner_account
    assert_equal owner_account["account_type"], "owner"
    assert_equal owner_account["balance"], "0.00"
  end

  test "returns [] if publisher has no verified channels" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:created)

    result = PublisherBalanceGetter.new(publisher: publisher).perform

    assert_equal result, []
  end
end
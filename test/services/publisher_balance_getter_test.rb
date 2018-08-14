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
    publisher = publishers(:uphold_connected) # has three channels

    channel_with_balance_id = publisher.channels.first.details.channel_identifier
    channel_without_balance_id = publisher.channels.second.details.channel_identifier

    stubbed_response_body = [{
      "account_id" => "#{channel_with_balance_id}",
      "balance" => "900"
    }]
    
    # stub empty response is returned by eyeshade for only one channel
    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
      to_return(status: 200, body: stubbed_response_body.to_json)
      
    result = PublisherBalanceGetter.new(publisher: publisher).perform

    assert_equal result.length, 3

    # demonstrate first result has balance
    assert_equal result.first["account_id"], channel_with_balance_id
    assert_equal result.first["balance"], "900"

    assert_equal result.third["account_id"], channel_without_balance_id
    assert_equal result.third["balance"], "0.00"
  end

  test "returns [] if publisher has no verified chanenls" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:created)

    result = PublisherBalanceGetter.new(publisher: publisher).perform

    assert_equal result, []
  end
end
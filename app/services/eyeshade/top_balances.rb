class Eyeshade::TopBalances < Eyeshade::BaseApiClient

  # Valid types
  CHANNEL = 'channel'.freeze
  OWNER = 'owner'.freeze
  UPHOLD = 'uphold'.freeze

  def initialize(type:)
    @type = type
  end

  def perform
    if Rails.application.secrets[:api_eyeshade_offline]
      result =
        if @type == OWNER
          perform_offline_owner
        elsif @type == CHANNEL
          perform_offline_channel
        elsif @type == UPHOLD
          perform_offline_uphold
        end
    else
      begin
        response = connection.get do |request|
          request.headers["Authorization"] = api_authorization_header
          request.url("/v1/accounts/balances/#{@type}/top?limit=1000")
        end
        result = JSON.parse(response.body)
      end
    end
    result
  end

  def perform_offline_channel
    [
      {
        "account_type"=>"channel",
        "account_id"=>"brave.com",
        "balance"=>"199.866965493802047491"
      }
    ]
  end

  def perform_offline_owner
    [
      {
        "account_type" => "owner",
        "account_id" => "publishers#uuid:#{Publisher.first.id}",
        "balance" => "123.123123123123123123"
      },
      {
        "account_type" => "owner",
        "account_id" => "publishers#uuid:#{Publisher.second.id}",
        "balance" => "200.000000000000000001"
      }
    ]
  end

  def perform_offline_uphold
    [
      {
        "account_type"=>"channel",
        "account_id"=>"brave.com",
        "balance"=>"199.866965493802047491"
      }
    ]
  end
end


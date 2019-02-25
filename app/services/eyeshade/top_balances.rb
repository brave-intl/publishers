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
      result = perform_offline
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

  def perform_offline
    [
      {
        "account_type"=>"channel",
        "account_id"=>"brave.com",
        "balance"=>"199.866965493802047491"
      }
    ]
  end
end


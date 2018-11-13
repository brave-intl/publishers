class Eyeshade::ReferralTotals < Eyeshade::BaseApiClient
  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("/v1/accounts/earnings/referrals/total")
    end

    JSON.parse(response.body)
  end

  def perform_offline
    [
      {
        "channel"=>"youtube#channel:dadsgdfssfdsa",
        "earnings"=>"40.000000000000000000",
        "account_id"=>"publishers#uuid:5913990b-b988-5964-a6c4-3d197a59920f"
      }
    ]
  end
end


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
        "channel"=>"youtube#channel:UC0jeQ0Y8y6n-FWZNDIRO2Ug",
        "earnings"=>"40.000000000000000000",
        "account_id"=>"publishers#uuid:a064ed75-b185-4841-aefb-7a0ed61731b2"
      }
    ]
  end
end


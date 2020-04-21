class Eyeshade::FetchSnapshot < Eyeshade::BaseApiClient
  def perform(payout_report_id:, global_identifier:)
    if Rails.application.secrets[:api_eyeshade_offline]
      result = perform_offline
    else
      begin
        response = connection.get do |request|
          request.headers["Authorization"] = api_authorization_header
          request.url("/v1/snapshots/#{payout_report_id}?account=#{channel_identifier}")
        end
        result = JSON.parse(response.body)
      end
    end
    result
  end

  def perform_offline
    {
      "id":"9e49faee-eeb5-48f4-ace8-97ad01f92773",
      "completed":true,
      "createdAt":"2020-04-21T13:55:40.279Z",
      "updatedAt":"2020-04-21T13:55:41.699Z",
      "items":[
        {
          "accountId":"duckduckgo.com",
          "accountType":"channel",
          "balance":"350992.753779548308452284"
        }
      ]
    }
  end
end

class Eyeshade::CreateSnapshot < Eyeshade::BaseApiClient
  def perform(payout_report_id:)
    if Rails.application.secrets[:api_eyeshade_offline]
      result = perform_offline
    else
      begin
        response = connection.post do |request|
          request.headers["Authorization"] = api_authorization_header
          request.url("/v1/snapshots/#{payout_report_id}")
        end
        result = JSON.parse(response.body)
      end
    end
    result
  end

  def perform_offline
    {
      "id":"9e49faee-eeb5-48f4-ace8-97ad01f92773",
    }
  end
end

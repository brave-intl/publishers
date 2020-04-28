class Eyeshade::CreateSnapshot < Eyeshade::BaseApiClient
  def perform(payout_report_id:)
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    begin
      response = connection.post do |request|
        request.headers["Authorization"] = api_authorization_header
        request.headers["Content-Type"] = "application/json"
        request.url("/v1/snapshots/")
        request.body = { "snapshotId" => payout_report_id }.to_json
      end
      result = JSON.parse(response.body)
    rescue
      LogException.perform(StandardError.new("Unable to create snapshot"), params: {})
    end
    result
  end

  def perform_offline
    {
      "id":"9e49faee-eeb5-48f4-ace8-97ad01f92773"
    }
  end
end

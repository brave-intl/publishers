# frozen_string_literal: true

class Eyeshade::Publishers < Eyeshade::BaseApiClient
  RESOURCE = "/v2/publishers"

  def create_settlement(body: )
    return {} if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.post do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("#{RESOURCE}/settlement")

      request.body = body.to_json
    end

    response.body
  end
end

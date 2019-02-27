# frozen_string_literal: true

class Eyeshade::Publishers < Eyeshade::BaseApiClient
  RESOURCE = "/v2/publishers"

  def create_settlement(body: )
    connection = Faraday.new(url: api_base_uri) do |config|
      config.request :json
      config.response :json
      config.adapter Faraday.default_adapter

      config.response(:logger, Rails.logger, bodies: true, headers: true)
      config.use(Faraday::Response::RaiseError)
    end

    response = connection.post do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("#{RESOURCE}/settlement")

      request.body = body
    end

    response.body
  end
end

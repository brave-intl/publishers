module Oauth2::Errors
  class UnknownError < StandardError
    attr_reader :response
    attr_reader :request

    def initialize(response:, request:)
      super
      @response = response
      @request = request
    end

    def message
      "OAuth2 request failed with status code #{@response.code}: #{@response} - #{@response.body}"
    end
  end
end

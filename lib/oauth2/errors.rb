module Oauth2::Errors
  class UnknownError < StandardError
    def initialize(response)
      super
      @response = response
    end

    def message
      "OAuth2 request failed with status code #{@response.code}: #{@response} - #{@response.body}"
    end
  end
end

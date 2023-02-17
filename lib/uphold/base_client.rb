# typed: true

module Uphold
  class BaseClient < BaseApiClient
    def initialize(access_token)
      @access_token = access_token
    end

    # TODO
    # Define abstract methods for common api endpoints
    # list, get, create, update
    private

    def api_base_uri
      (env == "production") ? "https://api.uphold.com" : "https://api-sandbox.uphold.com"
    end

    def env
      Rails.env
    end

    def api_authorization_header
      "Bearer #{@access_token}"
    end
  end
end

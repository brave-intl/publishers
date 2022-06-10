# typed: true

module Uphold
  class BaseClient < BaseApiClient
    extend T::Helpers
    extend T::Sig

    sig(:final) { params(access_token: String).void }
    def initialize(access_token)
      @access_token = access_token
    end

    # TODO
    # Define abstract methods for common api endpoints
    # list, get, create, update
    private

    sig(:final) { returns(String) }
    def api_base_uri
      env == "production" ? "https://api.uphold.com" : "https://api-sandbox.uphold.com"
    end

    def env
      Rails.env
    end

    sig(:final) { returns(String) }
    def api_authorization_header
      "Bearer #{@access_token}"
    end
  end
end

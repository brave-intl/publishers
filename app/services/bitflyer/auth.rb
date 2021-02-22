# frozen_string_literal: true

module Bitflyer
  class Auth < BaseApiClient
    include Initializable

    # For more information about how these URI templates are structured read the explaination in the RFC
    # https://github.com/sporkmonger/addressable
    # https://www.rfc-editor.org/rfc/rfc6570.txt
    PATH = Addressable::Template.new("/auth{/segments*}{?query*}")
    AUTHORIZATION_CODE = "authorization_code"
    REFRESH_TOKEN = "refresh_token"

    attr_reader :api_authorization_header
    attr_accessor :access_token, :refresh_token, :expires_in

    # Public: Crafts an authorization_url
    #
    # state - The state token which is passed in. This should be verified later
    # redirect_uri - The url which Bitflyer should redirect to once the connected
    #
    # Returns an authorization url for establishing OAuth credentials
    def self.authorize_url(state:, redirect_uri:)
      query = {
        client_id: Bitflyer.client_id,
        response_type: Bitflyer.response_type,
        scope: Bitflyer.scope,
        state: state,
        redirect_uri: redirect_uri,
      }

      authorization_path = PATH.expand(query: query, segments: nil)

      "#{Bitflyer.oauth_uri}#{authorization_path}"
    end

    # Public: Calls the Bitflyer API for accessing an access_token
    #
    # code - The code obtained from Bitflyer during the initial authorization flow
    #
    # Returns an Auth Object
    def self.token(code:, redirect_uri:)
      Auth.new.token(code: code, redirect_uri: redirect_uri)
    end

    # Temporarily keep a method on the class instance for API Requests until the following issue is resolved
    # https://github.com/brave-intl/publishers/issues/2779
    def token(code:, redirect_uri:)
      body = {
        client_id: Bitflyer.client_id,
        client_secret: Bitflyer.client_secret,
        grant_type: AUTHORIZATION_CODE,
        code: code,
        redirect_uri: redirect_uri,
      }
      response = post(PATH.expand(segments: 'token'), body)

      Auth.new(JSON.parse(response.body))
    end

    # Public: Requests a refresh token from the Bitflyer /auth/token.
    #
    # token - The refresh token made from initial token authorization flow
    #
    # Returns an auth object
    def self.refresh(token:)
      # This is a temporary stop gap until this issue is addressed
      # https://github.com/brave-intl/publishers/issues/2779
      Auth.new.refresh(token: token)
    end

    # Temporarily keep a method on the class instance for API Requests until the following issue is resolved
    # https://github.com/brave-intl/publishers/issues/2779
    def refresh(token:)
      body = {
        client_id: Bitflyer.client_id,
        client_secret: Bitflyer.client_secret,
        grant_type: REFRESH_TOKEN,
        refresh_token: token,
      }
      response = post(PATH.expand(segments: 'token'), body)

      Auth.new(JSON.parse(response.body))
    end

    def api_base_uri
      Bitflyer.oauth_uri
    end
  end
end

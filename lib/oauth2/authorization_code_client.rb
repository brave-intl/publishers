# typed: true
# frozen_string_literal: true

require "net/http"
require "uri"

# Client Credentials Grant Type (most common for OAuth2 flows): https://datatracker.ietf.org/doc/html/rfc6749#section-4.4
# FIXME: Rails is doing some magic to correct to OAuth2 in app/services but not in ./lib
class Oauth2::AuthorizationCodeClient
  extend T::Sig
  include Oauth2::Responses
  include Oauth2::Errors

  attr_reader :authorization_url
  attr_reader :token_url

  sig { params(client_id: String, client_secret: String, authorization_url: URI, token_url: URI).void }
  def initialize(client_id:, client_secret:, authorization_url:, token_url:)
    @client_id = client_id
    @client_secret = client_secret
    @authorization_url = authorization_url
    @token_url = token_url
    @options = {use_ssl: true}
  end

  # Generates URI for redirect/initiation of the oauth2 authorization code flow.
  # I.e. redirects to uphold/gemini/bitflyer etc.
  def authorization_code_url(redirect_uri:, scope:, state:)
    raise NotImplementedError
  end

  def access_token(authorization_code)
    raise NotImplementedError
  end

  sig { params(refresh_token: String).returns(T.any(RefreshTokenResponse, ErrorResponse)) }
  def refresh_token(refresh_token)
    request = Net::HTTP::Post.new(@token_url)
    request.set_form_data(
      "grant_type" => "refresh_token",
      "refresh_token" => refresh_token
    )

    handle_request(request, @token_url, RefreshTokenResponse)
  end

  private

  def handle_request(request, uri, success_struct)
    request.basic_auth(@client_id, @client_secret)
    request.content_type = "application/x-www-form-urlencoded"

    Net::HTTP.start(uri.hostname, uri.port, @options) do |http|
      response = http.request(request)
      is_success = response.is_a? Net::HTTPSuccess

      # To spec Oauth2 must return a 400 or success
      # Other response types should be returned directly for debugging
      # I.e. any response object is a failure by definition.
      if response.code == "400" || is_success
        struct = if is_success
          success_struct
        else
          ErrorResponse
        end
        struct.new(JSON.parse(response.body, symbolize_names: true))
      else
        raise UnknownError.new(response)
      end
    end
  end
end

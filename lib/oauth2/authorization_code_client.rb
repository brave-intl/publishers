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

  sig { params(client_id: String, client_secret: String, authorization_url: URI, token_url: URI, redirect_uri: URI, content_type: String).void }
  # In reality content type should not be a parameter, but we already have at least one case (Gemini) of an oauth flow that is not actually to spec.
  def initialize(client_id:, client_secret:, authorization_url:, token_url:, redirect_uri:, content_type: "application/x-www-form-urlencoded")
    @client_id = client_id
    @client_secret = client_secret
    @authorization_url = authorization_url
    @token_url = token_url
    @redirect_uri = redirect_uri
    @content_type = content_type
    @valid_content_type = "application/x-www-form-urlencoded"
    @invalid_content_type = "application/json"
    @options = {use_ssl: true}
  end

  # Generates URI for redirect/initiation of the oauth2 authorization code flow.
  # I.e. redirects to uphold/gemini/bitflyer etc.
  sig { params(scope: String, state: String).returns(String) }
  def authorization_code_url(scope:, state:)
    query = {
      response_type: "code",
      redirect_uri: @redirect_uri,
      scope: scope,
      state: state,
      client_id: @client_id
    }.to_query

    "#{@authorization_url}?#{query}"
  end

  sig { params(authorization_code: String).returns(T.any(AccessTokenResponse, ErrorResponse, UnknownError)) }
  def access_token(authorization_code)
    request = Net::HTTP::Post.new(@token_url)
    request.content_type = @content_type

    case @content_type
    when @invalid_content_type
      request.body = {
        code: authorization_code,
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "authorization_code",
        redirect_uri: @redirect_uri
      }.to_json
    else
      raise NotImplementedError
    end

    handle_request(request, @token_url, AccessTokenResponse)
  end

  sig { params(refresh_token: String).returns(T.any(RefreshTokenResponse, UnknownError, ErrorResponse)) }
  def refresh_token(refresh_token)
    request = Net::HTTP::Post.new(@token_url)
    request.content_type = @content_type

    case @content_type
    when @valid_content_type
      request.set_form_data(
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token
      )
      request.basic_auth(@client_id, @client_secret)
    when @invalid_content_type
      request.body = {
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      }.to_json
    else
      raise "Unsupported content_type #{@content_type}"
    end

    handle_request(request, @token_url, RefreshTokenResponse)
  end

  private

  def handle_request(request, uri, success_struct)
    Net::HTTP.start(uri.hostname, uri.port, @options) do |http|
      response = http.request(request)

      # To spec Oauth2 must return a 400 or success
      # Other response types should be returned directly for debugging
      return success_struct.new(JSON.parse(response.body, symbolize_names: true)) if response.is_a? Net::HTTPSuccess
      return UnknownError.new(response: response, request: request) if response.code != "400"

      begin
        # Serialize a to spec oauth2 400 response if it is returned
        ErrorResponse.new(JSON.parse(response.body, symbolize_names: true))
      rescue
        # If serialization fails, return an unknown error with debugging data
        UnknownError.new(response: response, request: request)
      end
    end
  end
end

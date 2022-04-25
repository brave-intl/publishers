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
  attr_reader :request
  attr_reader :response

  sig { params(config: T.class_of(Oauth2::Config::AuthorizationCode)).void }
  def initialize(config)
    @client_id = config.client_id
    @client_secret = config.client_secret
    @authorization_url = config.authorization_url
    @token_url = config.token_url
    @redirect_uri = config.redirect_uri
    @content_type = config.content_type
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
      request.set_form_data(
        code: authorization_code,
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "authorization_code",
        redirect_uri: @redirect_uri
      )
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
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "refresh_token",
        refresh_token: refresh_token
      )
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
      @response = response
      @request = request

      # To spec Oauth2 must return a 400 or success
      # Other response types should be returned directly for debugging
      return adapt_to_response(struct: success_struct, body: response.body) if response.is_a? Net::HTTPSuccess
      return UnknownError.new(response: response, request: request) if response.code != "400"

      begin
        # Serialize a to spec oauth2 400 response if it is returned
        adapt_to_response(struct: ErrorResponse, body: response.body)
      rescue
        # If serialization fails, return an unknown error with debugging data
        UnknownError.new(response: response, request: request)
      end
    end
  end

  #  Adapter pattern.  Filter to expected values in any response to ensure data is always appropriate for statically typed response objects
  #  or is true failure.
  def adapt_to_response(struct:, body:)
    out = {}

    parsed_body = JSON.parse(body, symbolize_names: true)
    struct.props.keys.each do |key|
      out[key] = parsed_body.fetch(key, nil)
    end

    struct.new(out)
  end
end

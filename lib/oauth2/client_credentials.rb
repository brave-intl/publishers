# typed: true
# frozen_string_literal: true

require "net/http"
require "uri"

# Client Credentials Grant Type (most common for OAuth2 flows): https://datatracker.ietf.org/doc/html/rfc6749#section-4.4
# FIXME: Rails is doing some magic to correct to OAuth2 in app/services but not in ./lib
class Oauth2::ClientCredentials
  extend T::Sig
  include Oauth2::Structs

  sig { params(client_id: String, client_secret: String, token_url: String).void }
  def initialize(client_id:, client_secret:, token_url:)
    @client_id = client_id
    @client_secret = client_secret
    @token_url = token_url
    @options = {use_ssl: true}
  end

  #      def access_token(scope = nil)
  #        # Below is a general flow of how this would normally work
  #        # for generating an access token from client credentials but it isn't tested
  #        raise NotImplementedError
  #        uri = URI.parse(@token_url)
  #        request = Net::HTTP::Post.new(uri)
  #        form_data = {"grant_type" => "client_credentials"}
  #
  #        if scope:
  #            formdata.merge("scope" => scope)
  #
  #        request.basic_auth(@client_id, @client_secret)
  #        request.content_type = "application/x-www-form-urlencoded"
  #        request.set_form_data(formdata)
  #
  #        response = Net::HTTP.start(uri.hostname, uri.port, @options) do |http|
  #          http.request(request)
  #        end
  #
  #        if response.is_a? Net::HttpSuccess
  #          struct = AccessTokenResponse
  #        else
  #          struct = ErrorResponse
  #        end
  #
  #        # To spec should always return a json response body.
  #        struct.new(JSON.parse(response.body))
  #      end

  sig { params(refresh_token: String).returns(T.any(RefreshTokenResponse, ErrorResponse)) }
  def refresh_token(refresh_token)
    uri = URI.parse(@token_url)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      "grant_type" => "refresh_token",
      "refresh_token" => refresh_token
    )

    handle_request(request, uri, RefreshTokenResponse)
  end

  private

  def handle_request(request, uri, success_struct)
    request.basic_auth(@client_id, @client_secret)
    request.content_type = "application/x-www-form-urlencoded"

    Net::HTTP.start(uri.hostname, uri.port, @options) do |http|
      response = http.request(request)

      struct = if response.is_a? Net::HTTPSuccess
        success_struct
      else
        ErrorResponse
      end

      struct.new(JSON.parse(response.body, symbolize_names: true))
    end
  end
end

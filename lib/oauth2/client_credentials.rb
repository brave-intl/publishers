# typed: true
# frozen_string_literal: true

require "net/http"
require "uri"

# Client Credentials Grant Type (most common for OAuth2 flows): https://datatracker.ietf.org/doc/html/rfc6749#section-4.4
# FIXME: Rails is doing some magic to correct to OAuth2 in app/services but not in ./lib
class Oauth2::ClientCredentials
  extend T::Sig
  include Oauth2::Structs
  class UnknownError < StandardError
    def initialize(response)
      super
      @response = response
    end

    def message
      "OAuth2 request failed with status code #{@response.code}: #{@response} - #{@response.body}"
    end
  end

  sig { params(client_id: String, client_secret: String, token_url: String).void }
  def initialize(client_id:, client_secret:, token_url:)
    @client_id = client_id
    @client_secret = client_secret
    @token_url = token_url
    @options = {use_ssl: true}
  end

  def access_token(scope = nil)
    raise NotImplementedError
  end

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

# typed: ignore
# frozen_string_literal: true

require "net/http"
require "uri"

module Uphold
  module Models
    class Authorization < Client
      PATH = "/oauth2/token"

      attr_accessor :access_token, :token_type, :expires_in, :refresh_token, :scope

      def initialize(params = {})
        super
      end

      # Refresh the Oauth access_token and refresh_token
      # Can also reduce scope if you pass in a scope reduction
      #
      # @param [UpholdConnection] connection The uphold connection to refresh.
      def refresh_authorization(uphold_connection)
        refresh_token = uphold_connection.refresh_token
        response = post_to_uphold(refresh_token)
        if !response.is_a? Net::HTTPSuccess
          return
        end
        response.body
      end

      # Example response:
      # {"access_token":"12345","token_type":"bearer","expires_in":3599,"refresh_token":"43210","scope":"cards:read user:read"}
      def post_to_uphold(refresh_token)
        uri = URI.parse("#{Rails.application.secrets[:uphold_api_uri]}#{PATH}")
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(Rails.application.secrets[:uphold_client_id], Rails.application.secrets[:uphold_client_secret])
        request.content_type = "application/x-www-form-urlencoded"
        request.set_form_data(
          "grant_type" => "refresh_token",
          "refresh_token" => refresh_token
        )

        req_options = {
          use_ssl: true
        }

        Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
      end
    end
  end
end

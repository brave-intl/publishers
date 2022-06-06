# typed: ignore
# frozen_string_literal: true

require "uri"
require "net/http"
require "json"
require "digest"
require "base64"

module Payment
  module Connection
    class BitflyerConnectionsController < Oauth2Controller
      def destroy
        I18n.locale = :ja
        bitflyer_connection = current_publisher.bitflyer_connection

        # Destroy our database records
        if bitflyer_connection.destroy
          redirect_to(home_publishers_path)
        else
          redirect_to(
            home_publishers_path,
            alert: I18n.t(
              "publishers.bitflyer_connections.destroy.error",
              errors: bitflyer_connection.errors.full_messages.join(", ")
            )
          )
        end
      end

      private

      # 1.) Set required state for Oauth2 Implementation
      # @debug is an optional flag that will return a json response from the callback
      # Helpful for explicit debugging and introspection of access token request response values.
      def set_controller_state
        @klass = BitflyerConnection
        @access_token_response = Oauth2::Responses::BitflyerAccessTokenResponse
      end

      # 2.) Bitflyer uses code exchange verification: https://datatracker.ietf.org/doc/html/rfc7636#section-4.1
      def code_challenge
        Digest::SHA256.base64digest(code_verifier).chomp("=").tr("+", "-").tr("/", "_")
      end

      # One way encoded(Varies through time + unique to provider + random/varies through sesion)
      def code_verifier
        Digest::SHA256.base64digest(current_publisher.current_sign_in_at.to_s + current_publisher.id + current_publisher.session_salt.to_s)
      end

      # 3.) Generate auth_url using code_challange verification
      def authorization_url
        @_authorization_url ||= client.authorization_code_url(
          state: @state,
          scope: @klass.oauth2_config.scope,
          code_challenge: code_challenge,
          code_challenge_method: "S256"
        )
      end

      # 4.) Make request using code_verifier
      def access_token_request
        client.access_token(params.require(:code), code_verifier: code_verifier)
      end
    end
  end
end

# typed: ignore
# frozen_string_literal: true

require "digest"

# Serves the OAuth2 redirect_uri registered with bitFlyer. The flow is started
# by Api::Nextv1::Connection::BitflyerConnectionsController#create.
module Payment
  module Connection
    class BitflyerConnectionsController < Oauth2Controller
      private

      def set_controller_state
        @klass = BitflyerConnection
        @access_token_response = Oauth2::Responses::BitflyerAccessTokenResponse
      end

      # Must match Api::Nextv1::Connection::BitflyerConnectionsController#code_verifier,
      # which derived the code_challenge sent to bitFlyer.
      def code_verifier
        Digest::SHA256.base64digest(current_publisher.current_sign_in_at.to_s + current_publisher.id + current_publisher.session_salt.to_s)
      end

      def access_token_request
        client.access_token(params.require(:code), code_verifier: code_verifier)
      end
    end
  end
end

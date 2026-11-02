# typed: ignore

# Serves the OAuth2 redirect_uri registered with Uphold. The flow is started
# by Api::Nextv1::Connection::UpholdConnectionsController#create.
module Payment
  module Connection
    class UpholdConnectionsController < Oauth2Controller
      private

      def set_controller_state
        @klass = UpholdConnection
        @klass.strict_create = true
      end
    end
  end
end

# typed: ignore

# Serves the OAuth2 redirect_uri registered with Uphold. The flow is started
# by Api::Nextv1::Connection::UpholdConnectionsController#create.
module Payment
  module Connection
    class UpholdConnectionsController < Oauth2Controller
      prepend_before_action :uphold_maintenance, only: [:callback]

      private

      def uphold_maintenance
        head :service_unavailable
      end

      def set_controller_state
        @klass = UpholdConnection
        @klass.strict_create = true
      end
    end
  end
end

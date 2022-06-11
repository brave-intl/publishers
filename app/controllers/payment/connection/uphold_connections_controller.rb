# typed: ignore
# This is the UpholdController for all publishers to connect their uphold account.
module Payment
  module Connection
    class UpholdConnectionsController < Oauth2Controller
      # publishers/disconnect_uphold
      def destroy
        current_publisher.uphold_connection&.destroy
        head :ok
      end

      private

      # 1.) Set required state for Oauth2 Implementation
      # @debug is an optional flag that will return a json response from the callback
      # Helpful for explicit debugging and introspection of access token request response values.
      def set_controller_state
        @klass = UpholdConnection
        @debug = true
      end
    end
  end
end

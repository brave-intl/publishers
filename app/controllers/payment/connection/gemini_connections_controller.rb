# typed: ignore
# frozen_string_literal: true

module Payment
  module Connection
    class GeminiConnectionsController < Oauth2Controller
      def destroy
        gemini_connection = current_publisher.gemini_connection

        # Destroy our database records
        if gemini_connection.destroy
          redirect_to(home_publishers_path, notice: I18n.t("publishers.gemini_connections.destroy.removed"))
        else
          redirect_to(
            home_publishers_path,
            alert: I18n.t(
              "publishers.gemini_connections.destroy.error",
              errors: gemini_connection.errors.full_messages.join(", ")
            )
          )
        end
      end

      private

      # 1.) Set required state for Oauth2 Implementation
      # @debug is an optional flag that will return a json response from the callback
      # Helpful for explicit debugging and introspection of access token request response values.
      def set_controller_state
        @klass = GeminiConnection
        # @debug = true
      end
    end
  end
end

# typed: ignore
# This is the UpholdController for all publishers to connect their uphold account.
module Payment
  module Connection
    # NOTE: To test this locally you have to  access the app from 127.0.0.1: Uphold does not allow localhost has a valid domain
    # and when you redirect back to 127.0.0.1 all your relevant cookies are lost.
    #
    # When you login through the email url, you need to copy the url and replace localhost with 127.0.0.1
    # and create your session with that domain.
    #
    # Took me a while to figure that out.

    class UpholdConnectionsController < Oauth2Controller
      def show
        publisher = current_publisher
        respond_to do |format|
          format.json do
            render(json: {
              uphold_status: publisher.uphold_connection&.uphold_status.to_s,
              uphold_is_member: publisher.uphold_connection&.is_member? || false,
              uphold_status_summary: uphold_status_summary(publisher),
              uphold_status_description: uphold_status_description(publisher),
              default_currency: publisher.uphold_connection&.default_currency,
              uphold_username: publisher.uphold_connection&.uphold_details&.username
            }, status: 200)
          end
        end
      end

      def update
        uphold_connection = current_publisher.uphold_connection
        return if uphold_connection.blank?

        send_emails = DateTime.now

        case params[:send_emails]
        when "forever"
          send_emails = UpholdConnection::FOREVER_DATE
        when "next_year"
          send_emails = 1.year.from_now
        end

        uphold_connection.update(send_emails: send_emails)
      end

      # publishers/disconnect_uphold
      def destroy
        # You can't remove your connection if you've been banned/suspended.
        # This is how we prevent you from reusing the connection.
        if !current_publisher.authorized_to_act? #
          head :unauthorized and return
        end

        current_publisher&.uphold_connection&.destroy
        head :ok
      end

      private

      # 1.) Set required state for Oauth2 Implementation
      # @debug is an optional flag that will return a json response from the callback
      # Helpful for explicit debugging and introspection of access token request response values.
      def set_controller_state
        @klass = UpholdConnection
        @klass.strict_create = true # toggle various restrictions on creating wallets. Useful for debugging.
      end
    end
  end
end

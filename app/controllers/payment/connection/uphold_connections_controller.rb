# This is the UpholdController for all publishers to connect their uphold account.
module Payment
  module Connection
    class UpholdConnectionsController < ApplicationController
      # TODO Refactor Uphold Status to not actually need helper
      # Traditional usage of helpers should really only be for views
      include PublishersHelper

      before_action :authenticate_publisher!

      # Generates an Uphold State Token for the user
      def create
        uphold_connection = UpholdConnection.find_or_create_by(publisher: current_publisher)
        uphold_connection.prepare_uphold_state_token!

        redirect_to Rails.application.secrets[:uphold_authorization_endpoint]
          .gsub("<UPHOLD_CLIENT_ID>", Rails.application.secrets[:uphold_client_id])
          .gsub("<UPHOLD_SCOPE>", Rails.application.secrets[:uphold_scope])
          .gsub("<STATE>", uphold_connection.uphold_state_token)
      end

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

      # This is the action which is redirected to from the Uphold OAuth flow.
      def edit
        uphold_connection = current_publisher.uphold_connection

        validate_uphold!(uphold_connection)
        validate_state!(uphold_connection)

        uphold_connection.receive_uphold_code(params[:code])

        ExchangeUpholdCodeForAccessTokenJob.perform_now(uphold_connection_id: uphold_connection.id)

        current_publisher.update(selected_wallet_provider: uphold_connection)

        uphold_connection.reload
        uphold_connection.sync_connection!
        create_uphold_report!(uphold_connection)

        redirect_to(home_publishers_path)
      rescue UpholdError, Faraday::Error => e
        Rails.logger.info("Uphold Error: #{e.message}")
        redirect_to(home_publishers_path, alert: t("publishers.uphold.create.uphold_error", message: e.message))
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
        publisher = current_publisher
        publisher.uphold_connection.destroy

        render json: {}
      end

      private

      class UpholdError < StandardError; end

      def create_uphold_report!(connection)
        uphold_id = connection.uphold_details&.id
        return if uphold_id.blank?
        # Return if we've already created a report for this id
        return if UpholdStatusReport.find_by(uphold_id: uphold_id).present?

        UpholdStatusReport.create(
          publisher: current_publisher,
          uphold_id: uphold_id
        )
      end

      def validate_uphold!(connection)
        # Ensure the uphold_state_token has been set. If not send back to try again
        raise UpholdError.new, t(".missing_state") if connection&.uphold_state_token.blank? && !connection.uphold_verified?

        # Alert for any errors from Uphold
        raise UpholdError.new, params[:error] if params[:error].present?
      end

      def validate_state!(connection)
        state_token = params[:state]
        raise UpholdError.new, t(".state_mismatch") if connection.uphold_state_token != state_token
      end
    end
  end
end

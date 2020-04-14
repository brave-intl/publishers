module Publishers
  class UpholdController < ApplicationController
    # TODO Refactor Uphold Status to not actually need helper
    # Traditional usage of helpers should really only be for views
    include PublishersHelper

    before_action :authenticate_publisher!

    def uphold_status
      publisher = current_publisher
      respond_to do |format|
        format.json do
          render(json: {
            uphold_status: publisher.uphold_connection&.uphold_status.to_s,
            uphold_status_summary: uphold_status_summary(publisher),
            uphold_status_description: uphold_status_description(publisher),
            uphold_status_class: uphold_status_class(publisher),
          }, status: 200)
        end
      end
    end

    def confirm_default_currency_params
      params.require(:publisher).permit(:default_currency)
    end

    # Records default currency preference
    # If user does not have Uphold's `cards:write` scope, we redirect to Uphold to get authorization
    # Card creation is done in #home
    def confirm_default_currency
      # TODO Consider refactoring this
      uphold_connection = current_publisher.uphold_connection

      uphold_connection.update(confirm_default_currency_params.merge(default_currency_confirmed_at: Time.now))

      if uphold_connection.can_create_uphold_cards?
        uphold_connection.create_uphold_cards

        # TODO do we need this refresh?
        render(json: {
          action: 'refresh',
          status: t("publishers.confirm_default_currency_modal.refreshing"),
          timeout: 2000,
        }, status: 200)
      else
        # Redirect the publisher to Uphold in order to authorize card creation.
        # Card will be created in #home when they return.
        render(json: {
          action: 'redirect',
          status: t("publishers.confirm_default_currency_modal.redirecting"),
          redirectURL: connect_uphold_publishers_path,
          timeout: 3000,
        }, status: 200)
      end
    end

    # Generates an Uphold State Token for the user
    def connect_uphold
      current_publisher.uphold_connection.prepare_uphold_state_token

      redirect_to Rails.application.secrets[:uphold_authorization_endpoint].
        gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id]).
        gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope]).
        gsub('<STATE>', current_publisher.uphold_connection.uphold_state_token)
    end

    # This creates the uphold connection
    # The route for this is by default publisher/uphold_verified
    def create
      uphold_connection = current_publisher.uphold_connection

      validate_uphold!(uphold_connection)
      validate_state!(uphold_connection)

      uphold_connection.receive_uphold_code(params[:code])

      ExchangeUpholdCodeForAccessTokenJob.perform_now(uphold_connection_id: uphold_connection.id)

      uphold_connection.reload
      # TODO: Should we drop this call from publishers_controller?
      uphold_connection.sync_from_uphold!
      if uphold_connection.has_duplicate_publisher_account?
        create_uphold_report!(connection: uphold_connection, duplicate: true)
        admin = Publisher.find_by(email: Rails.application.secrets[:zendesk_admin_email])
        PublisherNote.create(
          publisher_id: uphold_connection.publisher_id,
          note: "The user has a duplicate uphold address at uphold address: #{uphold_connection.address_id}",
          created_by_id: admin.id
        )
        uphold_connection.disconnect_uphold
        flash[:alert] = "You already have an existing uphold account. Please email us if you believe this is a mistake"
      else
        create_uphold_report!(connection: uphold_connection)
      end

      redirect_to(home_publishers_path)
    rescue UpholdError, Faraday::Error => e
      Rails.logger.info("Uphold Error: #{e.message}")
      redirect_to(home_publishers_path, alert: t(".uphold_error", message: e.message))
    end

    def update
      uphold_connection = current_publisher.uphold_connection
      return if uphold_connection.blank?

      send_emails = DateTime.now

      case params[:send_emails]
      when 'forever'
        send_emails = UpholdConnection::FOREVER_DATE
      when 'next_year'
        send_emails = 1.year.from_now
      end

      uphold_connection.update(send_emails: send_emails)
    end

    # publishers/disconnect_uphold
    def destroy
      publisher = current_publisher
      publisher.uphold_connection.disconnect_uphold

      head :no_content
    end

    private

    class UpholdError < StandardError; end

    def create_uphold_report!(connection:, duplicate: false)
      uphold_id = connection.uphold_details&.id
      return if uphold_id.blank?
      # Return if we've already created a report for this id
      return if UpholdStatusReport.find_by(uphold_id: uphold_id).present?

      UpholdStatusReport.create(
        publisher: current_publisher,
        uphold_id: uphold_id,
        duplicate: duplicate
      )
    end

    def validate_uphold!(connection)
      # Ensure the uphold_state_token has been set. If not send back to try again
      raise UpholdError.new, t('.missing_state') if connection&.uphold_state_token.blank? && !connection.uphold_verified?

      # Alert for any errors from Uphold
      raise UpholdError.new, params[:error] if params[:error].present?
    end

    def validate_state!(connection)
      state_token = params[:state]
      raise UpholdError.new, t('.state_mismatch') if connection.uphold_state_token != state_token
    end
  end
end

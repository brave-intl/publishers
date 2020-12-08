# frozen_string_literal: true

module Payment
  module Connection
    class GeminiConnectionsController < ApplicationController
      class GeminiError < StandardError; end
      before_action :authenticate_publisher!
      before_action :validate_connection!, only: :new

      def create
        gemini_connection = GeminiConnection.find_or_create_by(publisher: current_publisher)

        gemini_connection.prepare_state_token!

        redirect_to Gemini::Auth.authorize_url(
          state: gemini_connection.state_token,
          redirect_uri: publishers_gemini_connection_new_url(locale: nil)
        )
      end

      # This action is what is redirect from Gemini after the OAuth connection is redirected.
      def edit
        gemini_connection = GeminiConnection.find_by(publisher: current_publisher)

        authorization = Gemini::Auth.token(
          code: params[:code],
          redirect_uri: publishers_gemini_connection_new_url(locale: nil)
        )

        update_params = {
          access_token: authorization.access_token,
          refresh_token: authorization.refresh_token,
          expires_in: authorization.expires_in,
          access_expiration_time: authorization.expires_in.seconds.from_now,
        }

        if gemini_connection.update(update_params) &&
          current_publisher.update(selected_wallet_provider: gemini_connection) &&
          gemini_connection.sync_connection!
          redirect_to(home_publishers_path)
        else
          redirect_to(home_publishers_path, alert:  t(".gemini_error", message: gemini_connection.errors.full_messages.join(', ')))
        end
      rescue GeminiError => e
        redirect_to(home_publishers_path, alert: t(".gemini_error", message: e.message))
      end

      def destroy
        gemini_connection = current_publisher.gemini_connection

        # Destroy our database records
        if gemini_connection.destroy
          redirect_to(home_publishers_path, notice: I18n.t(".removed"))
        else
          redirect_to(
            home_publishers_path,
            alert: I18n.t(
              ".error",
              errors: gemini_connection.errors.full_messages.join(', ')
            )
          )
        end
      end

      private

      def validate_connection!
        connection = current_publisher.gemini_connection

        raise GeminiError.new, I18n.t('publishers.stripe_connections.new.missing_state') if connection&.state_token.blank?
        raise GeminiError.new, I18n.t('publishers.stripe_connections.new.state_mismatch') if connection.state_token != params[:state]
        raise GeminiError.new, params[:error] if params[:error].present?
      end
    end
  end

end

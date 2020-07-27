# frozen_string_literal: true

module Publishers
  class GeminiConnectionsController < ApplicationController
    class GeminiError < StandardError; end
    before_action :authenticate_publisher!
    before_action :validate_connection!, only: :new

    def connect
      gemini_connection = GeminiConnection.find_or_create_by(publisher: current_publisher)

      gemini_connection.prepare_state_token!

      redirect_to Gemini::Auth.authorize_url(
        state: gemini_connection.state_token,
        redirect_uri: new_gemini_connection_url(locale: nil)
      )
    end

    def new
      gemini_connection = GeminiConnection.find_by(publisher: current_publisher)

      authorization = Gemini::Auth.token(
        code: params[:code],
        redirect_uri: new_gemini_connection_url(locale: nil)
      )
      account = Gemini::Account.find(token: authorization.access_token)
      user = account.users.first

      gemini_connection.update(
        access_token: authorization.access_token,
        refresh_token: authorization.refresh_token,
        expires_in: authorization.expires_in,
        access_expiration_time: authorization.expires_in.seconds.from_now,
        display_name: user.name,
        status: user.status,
        country: user.country_code,
        is_verified: user.is_verified
      )

      redirect_to home_publishers_path
    rescue GeminiError => e
      redirect_to(home_publishers_path, alert: t(".gemini_error", message: e.message))
    end

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

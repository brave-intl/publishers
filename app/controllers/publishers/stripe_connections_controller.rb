# frozen_string_literal: true

module Publishers
  class StripeConnectionsController < ApplicationController
    class StripeError < StandardError; end
    before_action :authenticate_publisher!
    before_action :authorize!
    before_action :validate_connection!, only: :create

    STRIPE_SCOPE = "read_write"

    def connect
      stripe_connection = StripeConnection.find_or_create_by(publisher: current_publisher)

      stripe_connection.prepare_state_token!

      redirect_to Stripe::OAuth.authorize_url(
        scope: STRIPE_SCOPE,
        state: stripe_connection.state_token,
        redirect_uri: new_stripe_connection_url(locale: nil)
      )
    end

    def show
      stripe_connection = StripeConnection.find_or_create_by(publisher: current_publisher)
      render json: stripe_connection
    end

    def new
      # Raises a StripeError if the params are invalid.
      validate_connection!

      stripe_response = Stripe::OAuth.token({
        client_secret: Stripe.api_key,
        code: params[:code],
        grant_type: "authorization_code",
      })

      account = Stripe::Account.retrieve(stripe_response.stripe_user_id)
      stripe_connection = StripeConnection.find_or_create_by(publisher: current_publisher)

      stripe_connection.update(
        access_token: stripe_response.access_token,
        refresh_token: stripe_response.refresh_token,
        stripe_user_id: stripe_response.stripe_user_id,
        scope: stripe_response.scope,
        payouts_enabled: account.payouts_enabled,
        details_submitted: account.details_submitted,
        default_currency: account.default_currency,
        capabilities: account.capabilities.to_json,
        display_name: account.settings.dashboard.display_name,
        country: account.country
      )

      redirect_to home_publishers_path
    rescue Stripe::OAuth::InvalidGrantError, StripeError => e
      redirect_to(home_publishers_path, alert: t(".stripe_error", message: e.message))
    end

    def destroy
      stripe_connection = current_publisher.stripe_connection
      user_id = stripe_connection.stripe_user_id

      # Destroy our database records
      if stripe_connection.destroy
        # Deauthorize the account from user's Stripe Connect
        account = Stripe::Account.retrieve(user_id)
        account.deauthorize(Rails.application.secrets[:stripe_client_id])
        redirect_to(home_publishers_path, notice: I18n.t("publishers.stripe_connections.destroy.removed"))
      else
        redirect_to(
          home_publishers_path,
          alert: I18n.t(
            "publishers.stripe_connections.destroy.error",
            errors: stripe_connection.errors.full_messages.join(', ')
          )
        )
      end
    end

    private

    def authorize!
      raise StripeError.new, "Stripe is not enabled for your account" unless current_publisher.stripe_enabled?
    end

    def validate_connection!
      connection = current_publisher.stripe_connection

      raise StripeError.new, I18n.t('publishers.stripe_connections.new.missing_state') if connection&.state_token.blank?
      raise StripeError.new, I18n.t('publishers.stripe_connections.new.state_mismatch') if connection.state_token != params[:state]
      raise StripeError.new, params[:error] if params[:error].present?
    end
  end
end

module Connections
  class CurrenciesController < ApplicationController
    before_action :authenticate_publisher!
    before_action :validate_connection!

    def show
      render json: {
        supported_currencies: current_publisher.wallet_provider.supported_currencies,
        default_currency: current_publisher.wallet_provider.default_currency,
      }
    end

    def update
      if current_publisher.wallet_provider.update(currency_params)
        render json: {}
      else
        render json: { errors: current_publisher.wallet_provider.errors.full_messages }, status: 400
      end
    end

    private

    def currency_params
      params.permit(:default_currency)
    end

    def validate_connection!
      redirect_to(home_publishers_path, notice: I18n.t('.shared.error')) if current_publisher.wallet_provider.blank?
    end
  end
end

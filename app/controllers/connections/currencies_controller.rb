module Connections
  class CurrenciesController < ApplicationController
    before_action :authenticate_publisher!
    before_action :validate_connection!

    def show
      # Calls #supported_currencies on the associated crypto connection.
      render json: {
        supported_currencies: connection.supported_currencies,
        default_currency: connection.default_currency,
      }
    end

    def update
      # This connection will allow
      if connection.update(currency_params)
        render json: {}
      else
        render json: { errors: connection.errors.full_messages }, status: 400
      end
    end

    private

    def currency_params
      params.permit(:default_currency)
    end

    def validate_connection!
      redirect_to(home_publishers_path, notice: 'NO CONNECTION!!! TODO fix translation') if connection.blank?
    end

    # Internal: Defines and memoizes a connection for user.
    #
    # Returns returns GeminiConnection or an UpholdConnection
    def connection
      @connection ||= (current_publisher.gemini_connection || current_publisher.uphold_connection)
    end
  end
end

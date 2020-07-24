module Connections
  class CurrencyController < ApplicationController
    before_action :authenticate_publisher!
    before_action :validate_connection!

    def index
      # Calls #possible_currencies on the associated crypto connection.
      render json: {
        supported_currencies: connection.supported_currencies,
        default_currency: 'BAT',
      }
    end

    def update
      if connection.update(default_currency: params[:currency])
        redirect_to(home_publishers_path, notice: "TODO FIX THIS TRANSLATION")
      else
        redirect_to(
          home_publishers_path,
          alert: connection.errors.full_messages.join(', ')
        )
      end
    end

    private

    def validate_connection!
      redirect_to(home_publishers_path, notice: 'NO CONNECTION!!! TODO fix translation') if connection.blank?
    end

    # Internal: Defines and memoizes a connection for user.
    #
    # Returns eithera GeminiConnection or an UpholdConnection
    def connection
      @connection ||= (current_publisher.gemini_connection || current_publisher.uphold_connection)
    end
  end
end

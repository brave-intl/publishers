# frozen_string_literal: true

module Uphold
  module Models
    class User < Client
      include Initializable

      PATH = "/v0/me"

      attr_accessor :id, :address, :birthdate, :country, :currencies, :email, :firstName, :lastName,
        :settings, :memberAt, :status, :state, :verifications, :balances

      def initialize(params = {})
        super
      end

      # Finds the user
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      #
      # @return [array] of owner states
      def find(uphold_connection)
        token = JSON.parse(uphold_connection.uphold_access_parameters || "{}").try(:[], "access_token")

        Rails.logger.info("Connection #{uphold_connection.id} is missing access_token in uphold_access_parameters") and return if token.blank?

        response = get(PATH, {}, "Authorization: Bearer #{token}")

        Uphold::Models::User.new(JSON.parse(response.body))
      end
    end
  end
end

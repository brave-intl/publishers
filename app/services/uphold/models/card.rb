# frozen_string_literal: true
require 'addressable/template'

module Uphold
  module Models
    class Card < Client
      include Initializable

      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = "/v0/me/cards{?q}"

      attr_accessor :address, :available, :balance, :currency, :id, :label, :lastTransactionAt, :normalized, :settings

      def initialize(params = {})
        super
      end

      # Finds a card given the uphold_connection and a currency
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] currency The currency you want to find. By default searches for default_currency on UpholdConnection
      #
      # @return [Uphold::Models::Card] the card
      def find(uphold_connection, currency = nil)
        response = get(PATH.expand(q: currency || uphold_connection.default_currency), {}, authorization(uphold_connection))

        Uphold::Models::Card.new(JSON.parse(response.body))
      end

      # Finds a card given the uphold_connection and a currency
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] currency The currency you want to find. By default searches for default_currency on UpholdConnection
      # @param [string] label The label for the card
      #
      # @return [Uphold::Models::Card] the newly created card
      def create(uphold_connection, currency = nil, label = nil)
        params = {
          currency: currency || uphold_connection.default_currency,
          label: label || "Brave Rewards"
        }

        response = post(PATH, params, authorization(uphold_connection)))


      end

      def authorization(uphold_connection)
        token = JSON.parse(uphold_connection.uphold_access_parameters)["access_token"]
        "Authorization: Bearer #{token}"
      end
    end
  end
end

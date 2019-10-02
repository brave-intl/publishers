# frozen_string_literal: true

require "addressable/template"

module Uphold
  module Models
    class Card < Client
      include Initializable

      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = "/v0/me/cards"

      attr_accessor :address, :available, :balance, :currency, :id, :label, :lastTransactionAt, :normalized, :settings

      def initialize(params = {})
        super
      end

      # Finds a card given an id
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] id The id of the card you want to find. By default searches for the address on UpholdConnection
      #
      # @return [Uphold::Models::Card] the card
      def find(uphold_connection:, id: nil)
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?
        id = uphold_connection.address if id.blank?

        endpoint = PATH + "/" + id
        response = get(endpoint, {}, authorization(uphold_connection))

        Uphold::Models::Card.new(JSON.parse(response.body))
      end

      # Searches for a card given the uphold_connection and a currency
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] currency The currency you want to find. By default searches for default_currency on UpholdConnection
      #
      # @return [Uphold::Models::Card[]] an array of found cards
      def where(uphold_connection:, currency: nil)
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?
        Rails.logger.info("Connection #{uphold_connection.id} is missing a default currency and no currency was provided") and return if uphold_connection.default_currency.blank? && currency.blank?

        query = "currency:" + (currency || uphold_connection.default_currency)

        response = get(PATH, { q: query }, authorization(uphold_connection))

        cards = []
        if response.headers["Content-Encoding"].eql?("gzip")
          sio = StringIO.new(response.body)
          gz = Zlib::GzipReader.new(sio)
          cards = JSON.parse(gz.read)
        else
          cards = JSON.parse(response.body)
        end

        cards = cards.map { |c| Uphold::Models::Card.new(c) } if cards.present?

        cards
      end

      # Creates a card given the uphold_connection, currency, annd a label
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] currency The currency you want to find. By default searches for default_currency on UpholdConnection
      # @param [string] label The label for the card, defaults to "Brave Rewards"
      #
      # @return [Uphold::Models::Card] the newly created card
      def create(uphold_connection:, currency: nil, label: "Brave Rewards")
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?

        params = {
          currency: currency || uphold_connection.default_currency,
          label: label,
          settings: { starred: true },
        }

        response = post(PATH, params, authorization(uphold_connection))
        Uphold::Models::Card.new(JSON.parse(response.body))
      end

      def authorization(uphold_connection)
        token = JSON.parse(uphold_connection.uphold_access_parameters || "{}").try(:[], "access_token")
        "Authorization: Bearer #{token}"
      end
    end
  end
end

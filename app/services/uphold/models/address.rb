# frozen_string_literal: true

require 'addressable/template'

module Uphold
  module Models
    class Address < Client
      include Initializable

      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = Addressable::Template.new("/v0/me/cards/{id}/addresses")

      attr_accessor :formats, :type

      def initialize(params = {})
        super
      end

      # Lists all the addresses a specified card has
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] iid The id of the card you want to find.
      #
      # @return [Uphold::Models::Address[]] an array of th addresses
      def all(uphold_connection:, id: nil)
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?
        id = uphold_connection.address if id.blank?

        response = get(PATH.expand(id: id), {}, authorization(uphold_connection))

        JSON.parse(response.body).map { |a| Address.new(a) }
      end

      # Creates an address for a given card
      #
      # @param [string] network Network for the card, must be one of ["anonymous", "bitcoin", "bitcoin-cash", "bitcoin-gold", "dash", "ethereum", "litecoin", "voxel", "xrp-ledger"]
      #
      # @returns the id for the address
      def create(uphold_connection:, id:, network: "anonymous")
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?

        response = post(PATH.expand(id: id), { network: network }, authorization(uphold_connection))

        JSON.parse(response.body).dig('id')
      end

      def authorization(uphold_connection)
        token = JSON.parse(uphold_connection.uphold_access_parameters || "{}").try(:[], "access_token")
        "Authorization: Bearer #{token}"
      end
    end
  end
end

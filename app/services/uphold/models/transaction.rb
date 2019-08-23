# frozen_string_literal: true

require 'addressable/template'

module Uphold
  module Models
    class Transaction < Client
      include Initializable

      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = Addressable::Template.new("/v0/me/cards/{id}/transactions")

      attr_accessor :application, :createdAt, :denomination, :destination, :fees, :id, :message, :network,
        :normalized, :origin, :params, :priority, :reference, :status, :type

      def initialize(params = {})
        super
      end

      # Lists all the addresses a specified card has
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] iid The id of the card you want to find.
      #
      # @return [Uphold::Models::Address[]] an array of th addresses
      def all(uphold_connection:, id:)
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?

        response = get(PATH.expand(id: id), {}, authorization(uphold_connection))

        JSON.parse(response.body).map { |a| Transaction.new(a) }
      end

      def authorization(uphold_connection)
        token = JSON.parse(uphold_connection.uphold_access_parameters || "{}").try(:[], "access_token")
        "Authorization: Bearer #{token}"
      end
    end
  end
end

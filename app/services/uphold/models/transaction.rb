# frozen_string_literal: true

require "addressable/template"

module Uphold
  module Models
    class Transaction < Client
      include Initializable

      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = Addressable::Template.new("/v0/me/cards/{id}/transactions")

      BATCH_SIZE = 50

      attr_accessor :application, :createdAt, :denomination, :destination, :fees, :id, :message, :network,
                    :normalized, :origin, :params, :priority, :reference, :status, :type

      def initialize(params = {})
        super
      end

      # Lists all the addresses a specified card has
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] id The id of the card you want to find.
      #
      # @return [Uphold::Models::Address[]] an array of th addresses
      def all(id:, previously_cached: [], uphold_connection:)
        Rails.logger.info("Connection #{uphold_connection.id} is missing uphold_access_parameters") and return if uphold_connection.uphold_access_parameters.blank?

        page_index = 1

        transactions = []

        loop do
          start = (BATCH_SIZE * page_index) - BATCH_SIZE
          ending_index = start + BATCH_SIZE

          response = get(PATH.expand(id: id), {}, authorization(uphold_connection), { "Range" => "items=#{start}-#{ending_index}" })

          transactions += parse_response(response).map { |a| Uphold::Models::Transaction.new(a) }
          transaction_ids = transactions.map(&:id)

          range = response.headers["content-range"]
          total_items = range.split('/').second.to_i

          break if ending_index > total_items
          # Break if all the previously_cached values have been found in our transaction array
          break if previously_cached.present? && previously_cached.all? { |e| transaction_ids.include?(e) }

          page_index += 1
        end

        transactions
      end

      # Gets a specified transaction given an id
      #
      # id: The id for the uphold transaction
      #
      # Returns an Uphold Transaction
      def find(id:, uphold_connection:)
        path = Addressable::Template.new("/v0/me/transactions/{id}")
        response = get(path.expand(id: id), {}, authorization(uphold_connection))

        Uphold::Models::Transaction.new(parse_response(response))
      end

      # A transaction will have an anonymous origin if it came from another Uphold User
      # And that uphold user sent the funds through their anonymous card address.
      # This is functionality that realistically only the Browser uses to send tips.
      def anonymous_origin?
        origin.dig('node', 'type') == "anonymous"
      end

      def authorization(uphold_connection)
        token = JSON.parse(uphold_connection.uphold_access_parameters || "{}").try(:[], "access_token")
        "Authorization: Bearer #{token}"
      end

      def parse_response(response)
        if response.headers["Content-Encoding"].eql?("gzip")
          sio = StringIO.new(response.body)
          gz = Zlib::GzipReader.new(sio)
          JSON.parse(gz.read)
        else
          JSON.parse(response.body)
        end
      end
    end
  end
end

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
        @uphold_connection = params[:uphold_connection]
      end

      # Lists all the addresses a specified card has
      #
      # @param [UpholdConnection] connection The uphold connection to find.
      # @param [string] id The id of the card you want to find.
      #
      # @return [Uphold::Models::Address[]] an array of th addresses
      def all(id:)
        Rails.logger.info("Connection #{@uphold_connection.id} is missing uphold_access_parameters") and return if @uphold_connection.uphold_access_parameters.blank?

        page_index = 1

        transactions = []

        loop do
          start = (BATCH_SIZE * page_index) - BATCH_SIZE
          ending_index = start + BATCH_SIZE

          response = get(PATH.expand(id: id), {}, authorization(@uphold_connection), { "Range" => "items=#{start}-#{ending_index}" })

          transactions << parse_response(response).map { |a| Uphold::Models::Transaction.new(a) }

          range = response.headers["content-range"]
          total_items = range.split('/').second.to_i

          break if ending_index > total_items

          page_index += 1
        end

        transactions.flatten
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

# frozen_string_literal: true

module Sync
  module Connection
    class UpholdConnectionSyncJob
      include Sidekiq::Worker
      sidekiq_options queue: :scheduler

      def perform(publisher_id)
        uphold_connection = Publisher.find(publisher_id)&.uphold_connection
        return if uphold_connection.blank?
        return if uphold_connection.uphold_details.blank?

        # every request to the homepage let's sync from uphold
        uphold_connection.sync_connection!

        # Handles legacy case where user is missing an Uphold card
        uphold_connection.create_uphold_cards if uphold_connection.missing_card?
      end
    end
  end
end

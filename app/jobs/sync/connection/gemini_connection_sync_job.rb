# frozen_string_literal: true

module Sync
  module Connection
    class GeminiConnectionSyncJob < ApplicationJob
      queue_as :default

      def perform(publisher_id:)
        gemini_connection = Publisher.find(publisher_id).gemini_connection
        gemini_connection.sync_connection!
      end
    end
  end
end

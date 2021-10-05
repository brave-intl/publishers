# frozen_string_literal: true

module Sync
  module Connection
    class GeminiConnectionSyncJob
      include Sidekiq::Worker
      sidekiq_options queue: :scheduler

      def perform(publisher_id)
        gemini_connection = Publisher.find(publisher_id).gemini_connection
        gemini_connection.sync_connection!
      end
    end
  end
end

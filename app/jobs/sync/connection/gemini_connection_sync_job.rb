# frozen_string_literal: true

module Sync
  module Connection
    class GeminiConnectionSyncJob < ApplicationJob
      queue_as :default

      def perform(publisher_id:)
        gemini_connection = Publisher.find(publisher_id).gemini_connection
        return if gemini_connection&.access_token.blank?

        # If our access token has expired then we should refresh.
        if gemini_connection.access_token_expired?
          gemini_connection.refresh_authorization!
        end

        user = gemini_user(gemini_connection.access_token)
        recipient = find_or_create_recipient(gemini_connection.access_token)

        params = {
          recipient_id: recipient.recipient_id,
          display_name: user.name,
          status: user.status,
          country: user.country_code,
          is_verified: user.is_verified,
        }

        gemini_connection.update(params)
      end

      private

      # Internal: Calls the Gemini backend to retrieve the user's details
      #
      # Returns a Gemini::Account
      def gemini_user(access_token)
        account = Gemini::Account.find(token: access_token)
        account.users.first
      end

      # Internal: Calls the Gemini backend to find or create the existing address.
      #
      # Returns a Gemini::RecipientId
      def find_or_create_recipient(access_token)
        Gemini::RecipientId.find_or_create(token: access_token)
      end
    end
  end
end

# typed: ignore
require "test_helper"

module Sync
  module Connection
    class GeminiConnectionSyncJobTest < ActiveSupport::TestCase
      include MockGeminiResponses

      describe "the GeminiConnectionSyncJob runs" do
        let(:gemini_connection) { publishers(:gemini_completed).gemini_connection }
        let(:subject) { Sync::Connection::GeminiConnectionSyncJob.new.perform(publishers(:gemini_completed).id) }

        before do
          mock_gemini_auth_request!
          mock_gemini_account_request!
          mock_gemini_recipient_id!
          mock_gemini_channels_recipient_id!
          subject
        end

        it "sets the display name" do
          assert_equal "Alice Publisher", gemini_connection.display_name
        end

        it "sets the country code" do
          assert_equal "US", gemini_connection.country
        end

        it "sets the verified status" do
          assert_equal true, gemini_connection.is_verified
        end

        it "sets the status" do
          assert_equal "Active", gemini_connection.status
        end
      end
    end
  end
end

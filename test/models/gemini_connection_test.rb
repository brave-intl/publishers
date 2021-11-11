# typed: ignore
require "test_helper"
require "webmock/minitest"
require "jobs/sidekiq_test_case"

class GeminiConnectionTest < SidekiqTestCase
  include MockGeminiResponses

  describe "validations" do
    let(:gemini_connection) { gemini_connections(:default_connection) }

    describe "when recipient_id is nil" do
      before do
        gemini_connection.recipient_id = nil
      end

      it "is valid" do
        assert gemini_connection.valid?
      end
    end
  end

  describe "after destroy hook" do
    let(:gemini_connection) { gemini_connections(:connection_with_token) }
    let(:publisher) { publishers(:gemini_completed) }
    test "publisher no longer has a selected wallet provider" do
      assert_equal publisher.selected_wallet_provider, gemini_connection
      gemini_connection.destroy
      publisher.reload
      assert_nil publisher.selected_wallet_provider
    end
  end

  describe "refresh_authorization! retrieves a new token" do
    let(:gemini_connection) { gemini_connections(:connection_with_token) }
    subject { gemini_connection.refresh_authorization! }

    before do
      mock_gemini_auth_request!
      mock_gemini_account_request!
      mock_gemini_recipient_id!
    end

    it "refreshes the token" do
      assert_equal gemini_connection.access_token, "access_token"
      subject
      assert_equal gemini_connection.access_token, "km2bylijaDkceTOi2LiranELqdQqvsjFuHcSuQ5aU9jm"
    end
  end

  describe "#sync_connection" do
    let(:subject) { connection.sync_connection! }
    let(:connection) { gemini_connections(:connection_with_token) }

    before do
      mock_gemini_unverified_account_request!
    end

    it "queues a CreateGeminiRecipientIdsJob job" do
      assert_difference -> { CreateGeminiRecipientIdsJob.jobs.size } do
        subject
      end
    end
  end
end

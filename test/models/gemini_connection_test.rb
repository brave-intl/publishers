# typed: false

require "test_helper"
require "webmock/minitest"
require "jobs/sidekiq_test_case"

class GeminiConnectionTest < SidekiqTestCase
  include MockGeminiResponses
  include MockOauth2Responses
  include MockRewardsResponses

  let(:klass) { GeminiConnection }

  before do
    stub_rewards_parameters
  end

  describe "Oauth2::AuthorizationCodeBase" do
    let(:conn) { gemini_connections(:connection_with_token) }

    before do
      conn.access_expiration_time = 3600.seconds.ago
      conn.save!
    end

    describe "conn.class.oauth2_client" do
      it "should be truthy" do
        assert conn.class.oauth2_client
      end
    end

    describe "#refresh_authorization!" do
      describe "when successful" do
        before do
          mock_refresh_token_success(klass.oauth2_client.token_url)
        end

        test "it should return expected outout" do
          assert_instance_of(klass, conn.refresh_authorization!)
        end
      end

      describe "when unsuccessful" do
        before do
          mock_unknown_failure(klass.oauth2_client.token_url)
        end

        test "it should raise an error" do
          assert_raises(Oauth2::Errors::UnknownError) { conn.refresh_authorization! }
        end
      end

      describe "when 401" do
        describe "when valid oauth2 response" do
          let(:payload) { {error: "invalid_token", error_description: "Refresh token can only be used once"} }

          before do
            stub_request(:post, klass.oauth2_client.token_url)
              .to_return(status: 401, body: payload.to_json)
          end

          test "it return an error response" do
            assert_instance_of(Oauth2::Responses::ErrorResponse, conn.refresh_authorization!)
          end
        end

        describe "when invalid oauth2 response" do
          let(:payload) { {derp: "invalid_token", error_description: "Refresh token can only be used once"} }

          before do
            stub_request(:post, klass.oauth2_client.token_url)
              .to_return(status: 401, body: payload.to_json)
          end

          test "it raises an error" do
            assert_instance_of(Oauth2::Responses::ErrorResponse, conn.refresh_authorization!)
          end
        end
      end
    end
  end

  describe "scopes" do
    describe "refreshable" do
      before do
        assert GeminiConnection.refreshable.count == 0
      end

      describe "when true" do
        it "should not return connection" do
          GeminiConnection.first.update!(access_expiration_time: 2.days.ago, oauth_refresh_failed: false)
          assert GeminiConnection.refreshable.count == 1
        end
      end
    end

    describe "with_active_connection" do
      before do
        assert GeminiConnection.with_active_connection.count == 7
      end

      describe "when true" do
        it "should not return connection" do
          GeminiConnection.update_all(oauth_refresh_failed: true)
          assert GeminiConnection.with_active_connection.count == 0
        end
      end
    end

    describe "with_expired_tokens" do
      before do
        assert GeminiConnection.with_expired_tokens.count == 0
      end

      describe "when true" do
        it "should not return connection" do
          GeminiConnection.update_all(access_expiration_time: 2.days.ago)
          assert GeminiConnection.with_active_connection.count == 7
        end
      end
    end

    describe "with_active_connection" do
      before do
        assert GeminiConnection.with_active_connection.count == 7
      end

      describe "when true" do
        it "should not return connection" do
          GeminiConnection.update_all(oauth_refresh_failed: true)
          assert GeminiConnection.with_active_connection.count == 0
        end
      end
    end
  end

  describe "validations" do
    let(:gemini_connection) { gemini_connections(:default_connection) }

    describe "when recipient_id is nil" do
      before do
        gemini_connection.recipient_id = nil
      end

      it "is valid" do
        assert gemini_connection.valid?
      end

      it "is invalid when using a restricted address" do
        gemini_connection.recipient_id = OfacAddress.last.address
        gemini_connection.save
        refute gemini_connection.valid?
        assert gemini_connection.errors.full_messages.first == "Recipient can't be a banned address"
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

  describe "verify through gemini" do
    before do
      stub_rewards_parameters
      mock_refresh_token_success(klass.oauth2_client.token_url)
    end

    describe "when the account is from a blocked country" do
      let(:connection) { gemini_connections(:gemini_blocked_country_connection) }

      before do
        mock_gemini_blocked_country_account_request!
      end

      it "updates the connection in a non-payable state" do
        connection.verify_through_gemini
        connection.reload
        refute connection.payable?
      end
    end

    describe "when the account is from an allowed country" do
      let(:connection) { gemini_connections(:default_connection) }

      before do
        mock_gemini_account_request!
      end

      it "updates successfully" do
        assert(connection.verify_through_gemini)
      end
    end
  end

  describe "create new connection" do
    let(:access_token_response) {
      AccessTokenResponse.new(
        access_token: "km2bylijaDkceTOi2LiranELqdQqvsjFuHcSuQ5aU9jm",
        expires_in: 189561,
        scope: "Auditor",
        refresh_token: "6ooHciJa8nqwV5pFEyBAbt25Q7kZ16VAnS31p7xdSR9",
        token_type: "Bearer"
      )
    }

    before do
      stub_rewards_parameters
      mock_refresh_token_success(klass.oauth2_client.token_url)
      mock_gemini_recipient_id!
    end

    describe "when the account is from a blocked country" do
      let(:publisher) { publishers(:verified_blocked_country_gemini) }

      before do
        mock_gemini_blocked_country_account_request!
      end

      it "creates the connection in a non-payable state" do
        GeminiConnection.create_new_connection!(publisher, access_token_response)
        connection = GeminiConnection.last
        refute connection.payable?
      end
    end

    describe "when the account is not verified" do
      let(:publisher) { publishers(:gemini_not_completed) }

      before do
        mock_gemini_unverified_account_request!
      end

      it "should raise an error" do
        err = assert_raises(GeminiConnection::InvalidUserError) { GeminiConnection.create_new_connection!(publisher, access_token_response) }
        assert_equal err.message, I18n.t(".publishers.gemini_connections.new.no_kyc")
      end
    end

    describe "when the account is not active/capable" do
      let(:publisher) { publishers(:gemini_not_completed) }

      before do
        mock_gemini_incapable_account_request!
      end

      it "should raise an error" do
        err = assert_raises(GeminiConnection::CapabilityError) { GeminiConnection.create_new_connection!(publisher, access_token_response) }
        assert_equal err.message, I18n.t(".publishers.gemini_connections.new.limited_functionality")
      end
    end

    describe "when the account is from an allowed country" do
      let(:publisher) { publishers(:gemini_completed) }

      before do
        mock_gemini_account_request!
      end

      it "updates successfully" do
        assert(GeminiConnection.create_new_connection!(publisher, access_token_response))
      end

      it "queues a CreateGeminiRecipientIdsJob job" do
        assert_enqueued_jobs 0
        assert_enqueued_with(job: CreateGeminiRecipientIdsJob, queue: "default") do
          GeminiConnection.create_new_connection!(publisher, access_token_response)
        end
        assert_enqueued_jobs 1
      end

      it "relies on country_code if no validatedDocuments" do
        Gemini::GetValidationService.stubs(:perform).returns(nil)
        conn = GeminiConnection.create_new_connection!(publisher, access_token_response)
        assert_equal conn.reload.country, "US"
      end

      it "relies on validated country if validatedDocuments exists" do
        Gemini::GetValidationService.stubs(:perform).returns("PR")
        conn = GeminiConnection.create_new_connection!(publisher, access_token_response)
        assert_equal conn.reload.country, "PR"
      end
    end
  end

  describe "refresh_authorization! retrieves a new token" do
    let(:gemini_connection) { gemini_connections(:connection_with_token) }
    subject { gemini_connection.refresh_authorization! }

    before do
      mock_gemini_auth_request!
      mock_gemini_account_request!
      mock_gemini_recipient_id!
      gemini_connection.access_expiration_time = 3600.seconds.ago
      gemini_connection.save!
    end

    it "refreshes the token" do
      assert_equal gemini_connection.access_token, "access_token"
      subject
      assert_equal gemini_connection.access_token, "km2bylijaDkceTOi2LiranELqdQqvsjFuHcSuQ5aU9jm"
    end
  end

  describe "payable?" do
    describe "when from a blocked country" do
      let(:connection) { gemini_connections(:gemini_blocked_country_connection) }

      it "should not be payable" do
        refute connection.valid_country?
        refute connection.payable?
      end

      it "should be payable when the publisher has an exception flag" do
        connection.publisher.blocked_country_exception = true
        connection.publisher.save!
        connection.publisher.reload

        assert connection.valid_country?
      end
    end
  end
end

# typed: false
require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class UpholdConnectionTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Oauth2::Responses
  include MailerTestHelper
  include PromosHelper
  include EyeshadeHelper
  include MockOauth2Responses
  include MockUpholdResponses

  describe "#create_new_connection!" do
    let(:publisher) { publishers(:default) }
    let(:scope) { Oauth2::Config::Uphold.scope }
    let(:access_token_response ) {
      AccessTokenResponse.new(
        access_token: "derp",
        refresh_token: "derp",
        expires_in: 36000,
        token_type: "bearer",
        scope: scope
      )
    }

    describe "when not verified" do
      before do
        stub_get_user(member_at: nil) 
      end

      it "should raise an error" do
        assert_raises(UpholdConnection::UnverifiedConnectionError) { UpholdConnection.create_new_connection!(publisher, access_token_response) }
      end
    end

    describe "when wallet already exists" do
      before do
        conn = UpholdConnection.where.not(uphold_id: nil).select(:uphold_id).first
        stub_get_user(id: conn.uphold_id)
      end

      it "should raise an error" do
        assert_raises(UpholdConnection::DuplicateConnectionError) { UpholdConnection.create_new_connection!(publisher, access_token_response) }
      end
    end

    describe "when verified" do
      before do
        stub_get_user
      end

      describe "when wallet is new" do
        let(:status) { "blocked" }

        before do
          stub_get_user(id: "any unique value", status: status)
        end

        describe "if it is not ok" do
          it "it should raise an exception" do
            assert_raises(UpholdConnection::FlaggedConnectionError) { UpholdConnection.create_new_connection!(publisher, access_token_response) }
          end
        end

        describe "if it is ok" do
          let(:status) { "ok" } 

          describe "if has insufficient permissions" do
            let(:scope) { "" }

            it "it should raise an exception" do
              assert_raises(UpholdConnection::InsufficientScopeError) { UpholdConnection.create_new_connection!(publisher, access_token_response) }
            end
          end

          describe "if has sufficient permissions" do
            before do
              stub_list_cards
              stub_get_card
              stub_create_card
            end

            describe "if api requests are !successful" do
              before do
                mock_token_failure(UpholdConnection.oauth2_config.token_url)
              end

              it "it should create a connection" do
                assert_raises(UpholdConnection::WalletCreationError) { UpholdConnection.create_new_connection!(publisher, access_token_response) }
              end
            end

            describe "if api requests are successful" do
              before do
                mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
              end

              it "it should create a connection" do
                assert_instance_of(UpholdConnection, UpholdConnection.create_new_connection!(publisher, access_token_response))
              end
            end
          end
        end
      end
    end
  end

  describe "#uphold_client" do
    let(:conn) { uphold_connections(:google_connection) }

    it "should initialize" do
      assert_instance_of(Uphold::ConnectionClient, conn.uphold_client)
    end

    it "should have cards" do
      assert_instance_of(Uphold::Cards, conn.uphold_client.cards)
    end
  end

  describe "Oauth2::AuthorizationCodeBase" do
    let(:klass) { UpholdConnection }
    let(:conn) { uphold_connections(:google_connection) }

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
    end
  end

  describe "prepare_uphold_state" do
    let(:verified_connection) { uphold_connections(:verified_connection) }
    let(:subject) { verified_connection.prepare_uphold_state_token! }

    before do
      verified_connection.uphold_state_token = nil
      subject
    end

    it "is valid" do
      assert verified_connection.valid?
    end

    it "generates a new state token" do
      assert verified_connection.uphold_state_token
    end

    describe "when it is previously set" do
      existing_value = nil

      before do
        existing_value = verified_connection.uphold_state_token
        subject
      end

      it "does not change" do
        assert_equal existing_value, verified_connection.uphold_state_token
      end
    end
  end

  describe "validations" do
    let(:uphold_connection) { uphold_connections(:default_connection) }

    describe "when uphold_access_parameters is nil" do
      before do
        uphold_connection.uphold_access_parameters = nil
      end

      describe "when uphold_code is present" do
        before do
          uphold_connection.uphold_code = "foo"
        end

        it "is valid" do
          assert uphold_connection.valid?
        end

        describe "when uphold_verified is true" do
          before do
            uphold_connection.uphold_verified = true
          end

          it "is not valid" do
            refute uphold_connection.valid?
          end
        end
      end

      describe "when uphold_code is missing" do
        before do
          uphold_connection.uphold_code = nil
        end

        it "is valid" do
          assert uphold_connection.valid?
        end

        describe "when uphold_verified is true" do
          before do
            uphold_connection.uphold_verified = true
          end

          it "is valid" do
            assert uphold_connection.valid?
          end
        end
      end
    end

    describe "when uphold_access_parameters are present" do
      before do
        uphold_connection.uphold_access_parameters = "bar"
      end

      describe "when uphold_code is present" do
        before do
          uphold_connection.uphold_code = "foo"
        end

        it "is not valid" do
          refute uphold_connection.valid?
        end
      end

      describe "when uphold_code is missing" do
        before do
          uphold_connection.uphold_code = nil
        end

        it "is valid" do
          assert uphold_connection.valid?
        end
      end
    end
  end

  describe "receive_uphold_code" do
    uphold_connection = nil
    let(:subject) { uphold_connection.receive_uphold_code("secret!") }

    before do
      uphold_connection = uphold_connections(:verified_connection)
      uphold_connection.uphold_state_token = "1234"
      uphold_connection.uphold_code = nil
      uphold_connection.uphold_access_parameters = "1234"
      uphold_connection.uphold_verified = false

      subject
    end

    it "it sets uphold_code" do
      assert uphold_connection.uphold_code
    end

    it "clears the uphold_access_parameters field" do
      assert_nil uphold_connection.uphold_access_parameters
    end

    it "clears the uphold_state_token field" do
      assert_nil uphold_connection.uphold_state_token
    end
  end

  describe "verify_uphold_status" do
    uphold_connection = nil

    before do
      uphold_connection = uphold_connections(:verified_connection)
    end

    describe "when uphold_code, access_parameters, and uphold_verified are nil" do
      before do
        uphold_connection.uphold_code = nil
        uphold_connection.uphold_access_parameters = nil
        uphold_connection.uphold_verified = false
      end

      it "sets the status to unconnected" do
        assert_equal :unconnected, uphold_connection.uphold_status
      end
    end

    describe "record_refresh_failure!" do
      let(:verified_connection) { uphold_connections(:verified_connection) }

      before do
        assert !verified_connection.oauth_refresh_failed
        verified_connection.record_refresh_failure!
        verified_connection.reload
      end

      it "should update" do
        assert verified_connection.oauth_refresh_failed
      end
    end

    describe "when uphold_code is set but the other parameters are nil" do
      before do
        uphold_connection.uphold_code = "foo"
        uphold_connection.uphold_access_parameters = nil
        uphold_connection.uphold_verified = false
      end

      it "returns code_acquired" do
        assert_equal :code_acquired, uphold_connection.uphold_status
      end
    end

    describe "when uphold_code is nil but there are access parameters" do
      before do
        uphold_connection.uphold_code = nil
        uphold_connection.uphold_access_parameters = "foo"
        uphold_connection.uphold_verified = false
      end

      it "returns unconnected" do
        assert_equal :unconnected, uphold_connection.uphold_status
      end
    end

    describe "when uphold_code and access_parameters are nil" do
      before do
        uphold_connection.uphold_code = nil
        uphold_connection.uphold_access_parameters = nil
        uphold_connection.uphold_verified = true
      end

      it "returns reauthorize" do
        assert_equal :reauthorization_needed, uphold_connection.uphold_status
      end
    end

    describe "when status is OLD_ACCESS_CREDENTIALS" do
      before do
        uphold_connection.status = UpholdConnection::UpholdAccountState::OLD_ACCESS_CREDENTIALS
        uphold_connection.uphold_access_parameters = JSON.dump({a: 1})
        uphold_connection.uphold_verified = true
      end

      it "returns reauthorize" do
        assert_equal :reauthorization_needed, uphold_connection.uphold_status
      end
    end
  end
end

# typed: false
require "test_helper"
require "webmock/minitest"

class BitflyerConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  describe "#callback" do
    let(:scope) { "cards:write" }
    let(:publisher) { publishers(:google_verified) }
    let(:account_hash) { "a unique value" }
    let(:state) { "some value" }
    let(:cookie) { state }
    let(:path) { "/publishers/bitflyer_connection/new" }
    let(:verified_request) {
      ActionDispatch::Cookies::CookieJar.any_instance.stubs(:encrypted).returns({"_state" => cookie})
      get path, params: {code: "value", state: state}
    }

    before do
      BitflyerConnection.delete_all
      assert_equal(0, BitflyerConnection.count)
      sign_in(publisher)
    end

    describe "when invalid state" do
      let(:cookie) { "another value" }

      it "should raise an error" do
        assert_raises(ActionController::BadRequest) { get path, params: {code: "value", state: state} }
      end

      it "should not create a connection" do
        assert_equal(0, BitflyerConnection.count)
      end
    end

    describe "when valid state" do
      describe "when successful" do
        before do
          mock_refresh_token_success(BitflyerConnection.oauth2_client.token_url, scope: scope, account_hash: account_hash)
        end

        describe "when allow_debug?" do
          before do
            Oauth2Controller.any_instance.stubs(:allow_debug?).returns(true)
            verified_request
          end

          it "should return 200" do
            assert_equal(200, response.status)
          end
        end

        describe "when !allow_debug?" do
          before do
            verified_request
          end

          it "should redirect" do
            assert_equal(response.status, 302)
          end

          it "should create a new uphold_connection" do
            assert_equal(1, BitflyerConnection.count)
          end

          it "should not include a flash alert" do
            refute flash.alert
          end
        end
      end
    end

    describe "when unsuccessful" do
      before do
        I18n.locale = :ja
      end

      after do
        I18n.locale = :en
      end

      describe "when known error" do
        let(:scope) { "an invalid scope" }
        before do
          mock_refresh_token_success(BitflyerConnection.oauth2_client.token_url, scope: scope, account_hash: account_hash)
          verified_request
        end

        it "should redirect with a specific message" do
          assert_not_equal(I18n.t("shared.error"), flash.alert)
        end
      end

      describe "when unknown error" do
        before do
          mock_refresh_token_success(BitflyerConnection.oauth2_client.token_url, scope: scope, account_hash: account_hash)
          BitflyerConnection.stubs(:new).raises(RuntimeError)
          verified_request
        end

        it "should redirect with a generic message" do
          assert_equal(I18n.t("shared.error"), flash.alert)
        end
      end
    end
  end
end

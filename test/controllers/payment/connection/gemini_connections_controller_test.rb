# typed: false

require "test_helper"
require "webmock/minitest"

class GeminiConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include MockRewardsResponses
  include MockGeminiResponses

  describe "#callback" do
    let(:publisher) { publishers(:gemini_completed) }
    let(:state) { "some value" }
    let(:cookie) { state }
    let(:verified_request) {
      ActionDispatch::Cookies::CookieJar.any_instance.stubs(:encrypted).returns({"_state" => cookie})
      get "/publishers/gemini_connection/new", params: {code: "value", state: state}
    }

    before do
      stub_rewards_parameters
      GeminiConnection.delete_all
      assert_equal(0, GeminiConnection.count)
      sign_in(publisher)
    end

    describe "when invalid state" do
      let(:cookie) { "another value" }

      before do
        mock_gemini_unverified_account_request!
        # verified_request
        get "/publishers/gemini_connection/new", params: {code: "value", state: state}
      end

      it "should redirect" do
        assert_equal(response.status, 302)
      end

      it "should redirect with a generic message" do
        assert_equal(I18n.t("shared.error"), flash.alert)
      end

      it "should not create a connection" do
        assert_equal(0, GeminiConnection.count)
      end
    end

    describe "when valid state" do
      describe "when successful" do
        before do
          mock_refresh_token_success(GeminiConnection.oauth2_client.token_url)
          mock_gemini_recipient_id!
          mock_gemini_account_request!
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

          it "should create a new gemini_connection" do
            assert_equal(1, GeminiConnection.count)
          end

          it "should not include a flash alert" do
            refute flash.alert
          end
        end
      end
    end

    describe "when unsuccessful" do
      describe "when unknown error" do
        before do
          mock_unknown_failure(GeminiConnection.oauth2_client.token_url)
          mock_gemini_recipient_id!
          mock_gemini_account_request!
          verified_request
        end

        it "should redirect with a generic message" do
          assert_equal(I18n.t("shared.error"), flash.alert)
        end
      end

      describe "when blocked country error" do
        before do
          mock_refresh_token_success(GeminiConnection.oauth2_client.token_url)
          mock_gemini_recipient_id!
          mock_gemini_blocked_country_account_request!
          verified_request
        end

        it "should redirect with a blocked country error message" do
          assert flash.alert.include?("account is registered in a country that's not currently supported for connecting to Brave Creators")
        end
      end
    end
  end
end

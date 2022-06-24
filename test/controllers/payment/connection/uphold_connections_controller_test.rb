# typed: false
require "test_helper"
require "webmock/minitest"

class UpholdConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  describe "#callback" do
    let(:scope) { "cards:write" }
    let(:publisher) { publishers(:google_verified) }
    let(:state) { "some value" }
    let(:cookie) { state }
    let(:verified_request) {
      ActionDispatch::Cookies::CookieJar.any_instance.stubs(:encrypted).returns({"_state" => cookie})
      get "/publishers/uphold_verified", params: {code: "value", state: state}
    }

    before do
      UpholdConnection.delete_all
      assert_equal(0, UpholdConnection.count)
      sign_in(publisher)
    end

    describe "when invalid state" do
      let(:cookie) { "another value" }

      before do
        get "/publishers/uphold_verified", params: {code: "value", state: state}
      end

      it "should redirect" do
        assert_equal(response.status, 302)
      end

      it "should redirect with a generic message" do
        assert_equal(I18n.t("shared.error"), flash.alert)
      end

      it "should not create a connection" do
        assert_equal(0, UpholdConnection.count)
      end
    end

    describe "when valid state" do
      describe "when successful" do
        before do
          mock_refresh_token_success(UpholdConnection.oauth2_client.token_url, scope: scope)
          stub_get_user
          stub_get_card
          stub_list_cards
          stub_create_card
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
            assert_equal(1, UpholdConnection.count)
          end

          it "should not include a flash alert" do
            refute flash.alert
          end
        end
      end
    end

    describe "when unsuccessful" do
      describe "when allow_debug?" do
        before do
          mock_refresh_token_success(UpholdConnection.oauth2_client.token_url, scope: scope)
          stub_get_user
          stub_get_card
          Oauth2Controller.any_instance.stubs(:allow_debug?).returns(true)
        end

        it "should return 200" do
          assert_raises(Oauth2::Errors::ConnectionError) { verified_request }
        end
      end

      describe "when unknown error" do
        before do
          mock_refresh_token_success(UpholdConnection.oauth2_client.token_url, scope: scope)
          verified_request
        end

        it "should redirect with a generic message" do
          assert_equal(I18n.t("shared.error"), flash.alert)
        end
      end
    end
  end
end

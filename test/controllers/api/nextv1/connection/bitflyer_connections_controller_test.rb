# typed: false

require "test_helper"
require "webmock/minitest"
require "test_helpers/csrf_getter"

class Api::Nextv1::Connection::BitflyerConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include CsrfGetter

  let(:path) { "/api/nextv1/connection/bitflyer_connection" }
  let(:publisher) { publishers(:bitflyer_pub) }

  def setup
    ActionController::Base.allow_forgery_protection = true
  end

  def teardown
    ActionController::Base.allow_forgery_protection = false
    I18n.locale = I18n.default_locale
  end

  def json_headers
    {"HTTP_ACCEPT" => "application/json", "X-CSRF-Token" => (@csrf_token ||= get_csrf_token)}
  end

  def state_set_cookie_header
    Array(response.headers["set-cookie"]).flat_map { |h| h.split("\n") }.find { |c| c.start_with?("_state=") }
  end

  def encrypted_state_cookie
    jar = ActionDispatch::Cookies::CookieJar.build(ActionDispatch::TestRequest.create, cookies.to_hash)
    jar.encrypted[:_state]
  end

  def authorization_query
    Rack::Utils.parse_query(URI(response.parsed_body["authorization_url"]).query)
  end

  describe "#create" do
    before do
      sign_in(publisher)
      post path, headers: json_headers
    end

    it "returns an authorization url as json" do
      assert_response :ok
      assert response.parsed_body["authorization_url"].start_with?(BitflyerConnection.oauth2_config.authorization_url.to_s)
    end

    it "stores the state sent to the provider in an encrypted cookie" do
      state = authorization_query["state"]

      assert state.present?
      assert_equal state, encrypted_state_cookie
    end

    it "sets the state cookie as httponly and samesite lax" do
      header = state_set_cookie_header

      assert header.present?, "expected a _state cookie to be set"
      assert_match(/httponly/i, header)
      assert_match(/samesite=lax/i, header)
      refute_match(/;\s*secure/i, header)
    end

    it "uses PKCE with an S256 code challenge" do
      query = authorization_query

      assert_equal "S256", query["code_challenge_method"]
      assert query["code_challenge"].present?
    end

    it "generates a new state value for every request" do
      first_state = authorization_query["state"]
      post path, headers: json_headers

      refute_equal first_state, authorization_query["state"]
      assert_equal authorization_query["state"], encrypted_state_cookie
    end
  end

  describe "#create when signed out" do
    it "does not issue a state cookie" do
      post path, headers: json_headers

      assert_response :unauthorized
      assert_nil state_set_cookie_header
    end
  end

  describe "#destroy" do
    before do
      sign_in(publisher)
    end

    it "removes the connection and returns 200" do
      assert_difference("BitflyerConnection.count", -1) do
        delete path, headers: json_headers
      end

      assert_response :ok
      assert_equal({}, response.parsed_body)
      assert_nil publisher.reload.bitflyer_connection
    end

    it "returns 417 with the errors when the connection cannot be destroyed" do
      BitflyerConnection.any_instance.stubs(:destroy).returns(false)

      assert_no_difference("BitflyerConnection.count") do
        delete path, headers: json_headers
      end

      assert_response :expectation_failed
      assert response.parsed_body["errors"].present?
    end
  end

  describe "#destroy for a suspended publisher" do
    let(:publisher) { publishers(:bitflyer_suspended) }

    before do
      # Suspended publishers are halted before the CSRF cookie is set, so fetch it first.
      @csrf_token = get_csrf_token
      sign_in(publisher)
    end

    it "does not remove the connection" do
      assert_no_difference("BitflyerConnection.count") do
        delete path, headers: json_headers
      end

      assert_response :found
      assert_equal Rails.application.routes.url_helpers.suspended_error_publishers_path, response.parsed_body["location"]
    end
  end
end

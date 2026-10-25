# typed: false

require "test_helper"
require "webmock/minitest"
require "test_helpers/csrf_getter"

# Exercises Oauth2Controller#callback through the real flow: the Next.js API
# issues the state cookie, then the provider redirects back to the legacy
# redirect_uri. Cookies are never stubbed.
class Oauth2ControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include MockOauth2Responses
  include CsrfGetter

  let(:publisher) { publishers(:google_verified) }
  let(:callback_path) { "/publishers/bitflyer_connection/new" }
  let(:token_url) { BitflyerConnection.oauth2_client.token_url }

  before do
    I18n.locale = :en
    BitflyerConnection.delete_all
    sign_in(publisher)
  end

  after do
    I18n.locale = I18n.default_locale
  end

  def start_bitflyer_flow
    post "/api/nextv1/connection/bitflyer_connection", headers: {"HTTP_ACCEPT" => "application/json", "X-CSRF-Token" => (@csrf_token ||= get_csrf_token)}
    assert_response :ok
    Rack::Utils.parse_query(URI(response.parsed_body["authorization_url"]).query).fetch("state")
  end

  def bitflyer_callback(params)
    get callback_path, params: {code: "authorization-code"}.merge(params)
  end

  def stub_successful_token_exchange
    mock_refresh_token_success(token_url, scope: "cards:write", account_hash: "a unique value")
  end

  def set_cookie_headers
    Array(response.headers["set-cookie"]).flat_map { |h| h.split("\n") }
  end

  # Bitflyer controllers always render in Japanese (ApplicationController#switch_locale).
  def bitflyer_generic_error
    I18n.t("shared.error", locale: :ja)
  end

  def assert_rejected
    assert_equal home_publishers_path, URI(response.location).path
    assert_equal bitflyer_generic_error, flash.alert
    assert_equal 0, BitflyerConnection.where(publisher: publisher).count
  end

  describe "state verification" do
    before { stub_successful_token_exchange }

    it "rejects a callback with no state cookie and no state param" do
      bitflyer_callback({})

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "rejects a callback with no state cookie and a blank state param" do
      bitflyer_callback(state: "")

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "rejects an attacker-supplied state when no flow was started" do
      bitflyer_callback(state: SecureRandom.hex(64))

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "rejects a callback missing the state param when a state cookie exists" do
      start_bitflyer_flow
      bitflyer_callback({})

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "rejects a blank state param when a state cookie exists" do
      start_bitflyer_flow
      bitflyer_callback(state: "")

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "rejects a state that does not match the cookie" do
      start_bitflyer_flow
      bitflyer_callback(state: SecureRandom.hex(64))

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "rejects a state issued by a flow that has since been restarted" do
      stale_state = start_bitflyer_flow
      start_bitflyer_flow
      bitflyer_callback(state: stale_state)

      assert_rejected
      assert_not_requested :post, token_url
    end

    it "connects the wallet when the state matches the cookie" do
      state = start_bitflyer_flow
      bitflyer_callback(state: state)

      assert_equal home_publishers_path, URI(response.location).path
      assert_nil flash.alert
      assert_equal 1, BitflyerConnection.where(publisher: publisher).count
      assert_requested :post, token_url, times: 1
    end
  end

  describe "single-use state cookie" do
    it "clears the state cookie after a verified callback" do
      stub_successful_token_exchange
      state = start_bitflyer_flow
      bitflyer_callback(state: state)

      assert set_cookie_headers.any? { |c| c.start_with?("_state=;") }, "expected the _state cookie to be expired"
      assert cookies["_state"].blank?
    end

    it "rejects a replay of a captured callback" do
      stub_successful_token_exchange
      state = start_bitflyer_flow
      bitflyer_callback(state: state)
      assert_nil flash.alert

      bitflyer_callback(state: state)

      assert_equal home_publishers_path, URI(response.location).path
      assert_equal bitflyer_generic_error, flash.alert
      assert_requested :post, token_url, times: 1
    end

    it "consumes the state even when the token exchange fails" do
      stub_request(:post, token_url).to_return(
        {status: 400, body: {error: "invalid_grant", error_description: "failed"}.to_json},
        {status: 200, body: {access_token: "a", expires_in: 600, refresh_token: "r", token_type: "t", scope: "cards:write", account_hash: "h"}.to_json}
      )
      state = start_bitflyer_flow

      bitflyer_callback(state: state)
      assert_rejected

      bitflyer_callback(state: state)
      assert_rejected
      assert_requested :post, token_url, times: 1
    end
  end

  describe "uphold callback" do
    it "is blocked while uphold is under maintenance" do
      assert_no_difference("UpholdConnection.count") do
        get "/publishers/uphold_verified", params: {code: "authorization-code", state: "some value"}
      end

      assert_response :service_unavailable
    end
  end

  describe "when signed out" do
    it "does not exchange the code" do
      sign_out(publisher)
      stub_successful_token_exchange

      bitflyer_callback(state: "some value")

      assert_response :redirect
      refute_equal home_publishers_url, response.location
      assert_not_requested :post, token_url
    end
  end

  describe "cookies" do
    it "sets the session cookie with SameSite=Lax" do
      bitflyer_callback({})
      session_cookie = set_cookie_headers.find { |c| c.start_with?("_publishers_session=") }

      assert session_cookie.present?, "expected the session cookie to be written"
      assert_match(/samesite=lax/i, session_cookie)
    end

    it "does not mark the state cookie Secure outside production and staging" do
      start_bitflyer_flow
      state_cookie = set_cookie_headers.find { |c| c.start_with?("_state=") }

      assert_match(/samesite=lax/i, state_cookie)
      assert_match(/httponly/i, state_cookie)
      refute_match(/;\s*secure/i, state_cookie)
    end

    %w[production staging].each do |env|
      it "marks the state cookie Secure in #{env}" do
        @csrf_token = get_csrf_token
        Rails.env.stubs(:"#{env}?").returns(true)
        https!
        start_bitflyer_flow
        state_cookie = set_cookie_headers.find { |c| c.start_with?("_state=") }

        assert state_cookie.present?, "expected a _state cookie to be set"
        assert_match(/;\s*secure/i, state_cookie)
        assert_match(/samesite=lax/i, state_cookie)
      end
    end

    it "defaults cookies without an explicit SameSite to Lax" do
      assert_equal :lax, Rails.application.config.action_dispatch.cookies_same_site_protection

      start_bitflyer_flow
      csrf_cookie = set_cookie_headers.find { |c| c.start_with?("CSRF-TOKEN=") }

      assert csrf_cookie.present?
      assert_match(/samesite=lax/i, csrf_cookie)
    end
  end

  describe "debug mode" do
    it "is no longer available on either OAuth2 controller" do
      [Oauth2Controller, Api::Nextv1::Oauth2Controller].each do |controller|
        refute controller.method_defined?(:debug), "#{controller} still defines #debug"
        refute controller.private_method_defined?(:allow_debug?), "#{controller} still defines #allow_debug?"
      end
    end
  end
end

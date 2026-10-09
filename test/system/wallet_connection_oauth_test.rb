require "application_system_test_case"
require "webmock/minitest"

# The provider round-trip is entirely server-side redirects, so rack_test drives
# it without a browser: the API issues the state cookie, then the creator lands
# on the provider's redirect_uri.
class WalletConnectionOauthTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include MockRewardsResponses

  driven_by :rack_test

  let(:publisher) { publishers(:google_verified) }
  let(:token_url) { BitflyerConnection.oauth2_client.token_url }
  let(:generic_error) { I18n.t("shared.error", locale: :ja) }

  before do
    Capybara.app_host = nil
    stub_rewards_parameters
    BitflyerConnection.where(publisher: publisher).delete_all
    mock_refresh_token_success(token_url, scope: "cards:write", account_hash: "a unique value")
    sign_in(publisher)
  end

  def browser
    page.driver.browser
  end

  def csrf_token
    browser.get("/api/nextv1/registrations/tos_links")
    browser.rack_mock_session.cookie_jar["CSRF-TOKEN"]
  end

  # What the Next.js "Connect bitFlyer" button does before sending the creator to bitFlyer.
  def start_bitflyer_connection
    browser.post("/api/nextv1/connection/bitflyer_connection", {}, {"HTTP_ACCEPT" => "application/json", "HTTP_X_CSRF_TOKEN" => csrf_token})
    assert_equal 200, browser.last_response.status
    authorization_url = JSON.parse(browser.last_response.body).fetch("authorization_url")
    Rack::Utils.parse_query(URI(authorization_url).query).fetch("state")
  end

  def return_from_bitflyer(state:, code: "authorization-code")
    query = {code: code, state: state}.compact.to_query
    visit "/publishers/bitflyer_connection/new?#{query}"
  end

  def connected?
    BitflyerConnection.where(publisher: publisher).exists?
  end

  test "a creator who approves the bitFlyer connection has their wallet connected" do
    state = start_bitflyer_connection
    return_from_bitflyer(state: state)

    assert_equal home_publishers_path, current_path
    refute_content page, generic_error
    assert connected?
  end

  test "a forged callback link with no state is rejected" do
    return_from_bitflyer(state: nil, code: "attacker-code")

    assert_equal home_publishers_path, current_path
    assert_content page, generic_error
    refute connected?
    assert_not_requested :post, token_url
  end

  test "a forged callback link with an empty state is rejected" do
    return_from_bitflyer(state: "", code: "attacker-code")

    assert_content page, generic_error
    refute connected?
    assert_not_requested :post, token_url
  end

  test "a callback carrying someone else's state is rejected even mid-flow" do
    start_bitflyer_connection
    return_from_bitflyer(state: SecureRandom.hex(64), code: "attacker-code")

    assert_content page, generic_error
    refute connected?
    assert_not_requested :post, token_url
  end

  test "revisiting a completed callback URL does not reuse the authorization" do
    state = start_bitflyer_connection
    return_from_bitflyer(state: state)
    assert connected?

    return_from_bitflyer(state: state)

    assert_content page, generic_error
    assert_requested :post, token_url, times: 1
  end

  test "a creator who restarts the connection can only finish the latest attempt" do
    abandoned_state = start_bitflyer_connection
    latest_state = start_bitflyer_connection

    return_from_bitflyer(state: abandoned_state)
    assert_content page, generic_error
    refute connected?

    return_from_bitflyer(state: latest_state)
    refute_content page, generic_error
    assert connected?
  end
end

# typed: false

require "test_helper"

# Security regression tests for the unverified-channel public page vulnerability.
#
# Attack chain: a publisher registers any domain (e.g. mozilla.org), attaches a
# wallet to the unverified channel, and the public contribution page is served
# immediately — routing contributions to an attacker-controlled address and
# displaying attacker-controlled branding before any domain ownership is proven.
class Api::Nextv1::PublicChannelControllerTest < ActionDispatch::IntegrationTest
  # -----------------------------------------------------------------------
  # RED tests — document the vulnerability.  These assert the SECURE behavior
  # that the fix must produce; they FAIL on the buggy controller and PASS after.
  # -----------------------------------------------------------------------

  test "public endpoint does NOT expose an unverified channel even when it has a wallet attached" do
    unverified = channels(:default)
    assert_equal false, unverified.verified?, "precondition: fixture must be unverified"
    assert unverified.crypto_addresses.any?, "precondition: fixture must have a wallet to trigger the bug"

    get "/api/nextv1/public_channel/#{unverified.public_identifier}"

    assert_response :not_found,
      "Unverified channel must not be served publicly (got #{response.status})"
    body = JSON.parse(response.body)
    assert body["crypto_addresses"].nil?,
      "Response must not include wallet addresses for unverified channels"
  end

  test "public endpoint serves a verified channel normally" do
    verified = channels(:verified)
    assert_equal true, verified.verified?, "precondition: fixture must be verified"

    get "/api/nextv1/public_channel/#{verified.public_identifier}"

    assert_response :success
    body = JSON.parse(response.body)
    assert body["url"].present?, "Verified channel response must include url"
  end

  test "public endpoint returns 404 for an unverified channel looked up by public_name" do
    unverified = channels(:default)
    unverified.update_column(:public_name, "unverified_brand_test")

    get "/api/nextv1/public_channel/unverified_brand_test"

    assert_response :not_found,
      "Unverified channel must not be found by public_name (got #{response.status})"
  ensure
    unverified.update_column(:public_name, nil)
  end
end

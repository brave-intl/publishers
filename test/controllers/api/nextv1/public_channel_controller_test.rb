require "test_helper"

class Api::Nextv1::PublicChannelControllerTest < ActionDispatch::IntegrationTest
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

  test "public endpoint does NOT serve a channel whose publisher is suspended" do
    channel = channels(:verified)
    channel.publisher.suspend!
    assert_predicate channel.publisher.reload, :suspended?, "precondition: publisher must be suspended"

    get "/api/nextv1/public_channel/#{channel.public_identifier}"

    assert_response :not_found,
      "Suspended publisher's channel must not be served publicly (got #{response.status})"
    assert_nil JSON.parse(response.body)["crypto_addresses"],
      "Response must not include wallet addresses for a suspended publisher"
  end

  test "public endpoint does NOT serve a channel whose publisher is suspended, looked up by public_name" do
    channel = channels(:verified)
    channel.publisher.suspend!
    channel.update_column(:public_name, "suspended_brand_test")

    get "/api/nextv1/public_channel/suspended_brand_test"

    assert_response :not_found,
      "Suspended publisher must not be reachable by public_name either (got #{response.status})"
  ensure
    channel.update_column(:public_name, nil)
  end

  test "public endpoint does NOT serve a channel whose publisher is excluded from payout" do
    channel = channels(:verified)
    channel.publisher.update!(excluded_from_payout: true)

    get "/api/nextv1/public_channel/#{channel.public_identifier}"

    assert_response :not_found,
      "Publisher excluded from payout must not be served publicly (got #{response.status})"
  end

  test "public endpoint does NOT serve a channel whose publisher is limited to user funds" do
    channel = channels(:verified)
    PublisherStatusUpdate.create!(
      publisher: channel.publisher,
      status: PublisherStatusUpdate::ONLY_USER_FUNDS
    )

    get "/api/nextv1/public_channel/#{channel.public_identifier}"

    assert_response :not_found,
      "Only-user-funds publisher must not be served publicly (got #{response.status})"
  end

  test "public endpoint still serves a channel whose publisher is payable" do
    channel = channels(:verified)
    assert_predicate channel.publisher, :brave_payable?, "precondition: publisher must be payable"

    get "/api/nextv1/public_channel/#{channel.public_identifier}"

    assert_response :success,
      "A channel belonging to a publisher in good standing must still be served (got #{response.status})"
    assert JSON.parse(response.body)["crypto_addresses"].present?,
      "Payable publisher's response must still include wallet addresses"
  end
end

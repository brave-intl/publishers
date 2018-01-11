require "test_helper"
require "shared/mailer_test_helper"

class Api::OwnersControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  PUBLISHER_PARAMS = {
    publisher: {
      email: "alice@example.com",
      name: "Alice the Pyramid",
      phone: "+14159001420"
    }
  }.freeze

  VERIFIED_PUBLISHER_PARAMS = PUBLISHER_PARAMS.deep_merge(
    publisher: {
      verified: true
    }
  ).freeze

  test "returns error for omitted notification type" do
    owner = publishers(:verified)

    post "/api/owners/#{URI.escape(owner.owner_identifier)}/notifications"

    assert_equal 400, response.status
    assert_match "parameter 'type' is required", response.body
  end

  test "returns error for invalid notification type" do
    owner = publishers(:verified)

    post "/api/owners/#{URI.escape(owner.owner_identifier)}/notifications?type=invalid_type"

    assert_equal 400, response.status
    assert_match "invalid", response.body
  end

  test "send email for valid notification type" do
    owner = publishers(:verified)

    assert_enqueued_emails 2 do
      post "/api/owners/#{URI.escape(owner.owner_identifier)}/notifications?type=verified_no_wallet"
    end

    assert_equal 200, response.status
  end

  test "can get owner by owner_identifier" do
    owner = publishers(:verified)

    get "/api/owners/#{URI.escape(owner.owner_identifier)}"

    assert_equal 200, response.status
  end
end

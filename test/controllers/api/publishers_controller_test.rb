require "test_helper"
require "shared/mailer_test_helper"

class Api::PublishersControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  PUBLISHER_PARAMS = {
    publisher: {
      email: "alice@example.com",
      brave_publisher_id: "pyramid.net",
      name: "Alice the Pyramid",
      phone: "+14159001420",
      show_verification_status: true,
    }
  }.freeze

  VERIFIED_PUBLISHER_PARAMS = PUBLISHER_PARAMS.deep_merge(
    publisher: {
      verified: true
    }
  ).freeze

  test "can create Publishers" do
    assert_difference("Publisher.count", 1) do
      post(create_api_publishers_path, params: PUBLISHER_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    assert(publisher.created_via_api)
  end

  test "can create verified Publishers" do
    assert_difference("Publisher.count", 1) do
      post(create_api_publishers_path, params: VERIFIED_PUBLISHER_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    assert(publisher.verified)
  end

  test "when creating verified Publishers, email is sent" do
    assert_enqueued_emails(2) do
      post(create_api_publishers_path, params: VERIFIED_PUBLISHER_PARAMS)
    end
  end

  test "can create verified Publisher with an existing unverified Publisher with the brave_publisher_id" do
    params = VERIFIED_PUBLISHER_PARAMS.deep_merge(
      publisher: {
        brave_publisher_id: publishers(:default)
      }
    )
    assert_difference("Publisher.count", 1) do
      post(create_api_publishers_path, params: params)
    end
  end

  test "can't create verified Publisher with an existing verified Publisher with the brave_publisher_id" do
    params = VERIFIED_PUBLISHER_PARAMS.deep_merge(
      publisher: {
        brave_publisher_id: publishers(:verified)
      }
    )
    assert_no_difference("Publisher.count") do
      post(create_api_publishers_path, params: params)
    end
    assert_match("brave_publisher_id", response.body)
    assert_match("verified", response.body)
  end

  test "can delete unverified Publishers" do
    verified_publisher = publishers(:verified)
    brave_publisher_id = verified_publisher.brave_publisher_id

    fake1_publisher = publishers(:fake1)
    fake2_publisher = publishers(:fake2)

    assert_equal brave_publisher_id, fake1_publisher.brave_publisher_id
    assert_equal brave_publisher_id, fake2_publisher.brave_publisher_id
    refute fake1_publisher.verified?
    refute fake2_publisher.verified?

    assert_difference("Publisher.count", -2) do
      delete(destroy_api_publishers_path({ brave_publisher_id: brave_publisher_id }))
    end

    verified_publisher.reload
    assert_equal brave_publisher_id, verified_publisher.brave_publisher_id

    assert_raises(ActiveRecord::RecordNotFound) do
      fake1_publisher.reload
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      fake2_publisher.reload
    end

    assert_equal(200, response.status)
  end

  test "delete is successful even for publisher IDs with no matches" do
    assert_difference("Publisher.count", 0) do
      delete(destroy_api_publishers_path({ brave_publisher_id: 'totally_made_up.com' }))
    end

    assert_equal(200, response.status)
  end

  test "show_verification_status returns as false if nil" do
    default_publisher = publishers(:default)
    assert_nil default_publisher.show_verification_status

    get "/api/publishers/#{default_publisher.brave_publisher_id}"

    assert_equal(200, response.status)
    refute_nil JSON.parse(response.body)[0]['show_verification_status']
  end

  test "show_verification_status returns as true if true" do
    uphold_connected = publishers(:uphold_connected)
    assert uphold_connected.show_verification_status

    get "/api/publishers/#{uphold_connected.brave_publisher_id}"

    assert_equal(200, response.status)
    assert JSON.parse(response.body)[0]['show_verification_status']
  end

  test "returns error for omitted notification type" do
    verified_publisher = publishers(:verified)

    post "/api/publishers/#{verified_publisher.brave_publisher_id}/notifications"

    assert_equal 400, response.status
    assert_match "parameter 'type' is required", response.body
  end

  test "returns error for invalid notification type" do
    verified_publisher = publishers(:verified)

    post "/api/publishers/#{verified_publisher.brave_publisher_id}/notifications?type=invalid_type"

    assert_equal 400, response.status
    assert_match "invalid", response.body
  end

  test "send email for valid notification type" do
    verified_publisher = publishers(:verified)

    assert_enqueued_emails 2 do
      post "/api/publishers/#{verified_publisher.brave_publisher_id}/notifications?type=verified_no_wallet"
    end

    assert_equal 200, response.status
  end
end

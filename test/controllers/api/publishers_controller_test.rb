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
end

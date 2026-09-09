require "test_helper"
require "minitest/mock"

class Api::Nextv1::BaseControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  GATED_ENDPOINT = "/api/nextv1/publishers/me"

  test "an active publisher reaches the endpoint" do
    publisher = publishers(:verified)
    assert_predicate publisher, :authorized_to_act?, "precondition: fixture must be in good standing"
    sign_in publisher

    get GATED_ENDPOINT

    assert_response :success
  end

  test "a suspended publisher is redirected to the suspended error page" do
    publisher = publishers(:suspended)
    assert_predicate publisher, :suspended?, "precondition: fixture must be suspended"
    sign_in publisher

    get GATED_ENDPOINT

    assert_response :found
    assert_equal suspended_error_publishers_path, JSON.parse(response.body)["location"]
  end

  test "a suspended publisher is given no account data in the response" do
    publisher = publishers(:suspended)
    sign_in publisher

    get GATED_ENDPOINT

    body = JSON.parse(response.body)
    assert_equal ["location"], body.keys
    assert_nil body["email"]
  end

  test "a publisher sharing an uphold id with suspended accounts is suspended on the spot" do
    publisher = publishers(:verified)
    assert_not publisher.suspended?, "precondition: fixture must start unsuspended"
    sign_in publisher

    UpholdConnection.stub(:is_suspended?, true) do
      get GATED_ENDPOINT
    end

    assert_response :found
    assert_predicate publisher.reload, :suspended?
  end

  test "automatic suspension records an explanatory publisher note" do
    publisher = publishers(:verified)
    sign_in publisher

    assert_difference -> { PublisherNote.where(publisher: publisher).count }, 1 do
      UpholdConnection.stub(:is_suspended?, true) do
        get GATED_ENDPOINT
      end
    end

    assert_match "Automated suspension", PublisherNote.where(publisher: publisher).last.note
  end

  test "an already suspended publisher is not suspended a second time" do
    publisher = publishers(:suspended)
    sign_in publisher

    assert_no_difference -> { PublisherStatusUpdate.where(publisher: publisher).count } do
      get GATED_ENDPOINT
    end

    assert_response :found
  end

  test "an unauthenticated request is stopped by authentication, not the suspension gate" do
    get GATED_ENDPOINT

    assert_response :unauthorized
  end

  test "the public channel endpoint skips the gate even for a suspended publisher" do
    sign_in publishers(:suspended)
    channel = channels(:verified)

    get "/api/nextv1/public_channel/#{channel.public_identifier}"

    assert_not_equal 302, response.status
  end
end

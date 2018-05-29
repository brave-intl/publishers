require "test_helper"
require "shared/mailer_test_helper"

class Api::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "can get owner's youtube channel by identifier" do
    channel = channels(:global_yt2)
    publisher = channel.publisher

    get "/api/owners/#{URI.escape(publisher.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_equal 200, response.status

    assert_match /#{channel.details.channel_identifier}/, response.body
  end

  test "can get owner's site channel by identifier" do
    channel = channels(:verified)
    publisher = channel.publisher

    url = "/api/owners/#{URI.escape(publisher.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_routing url, format: :json, controller: "api/channels", action: "show", owner_id: publisher.owner_identifier, channel_id: channel.details.channel_identifier

    get url

    assert_equal 200, response.status

    assert_match /#{channel.details.channel_identifier}/, response.body
  end

  test "returns error for omitted notification type" do
    channel = channels(:verified)
    owner = channel.publisher

    post "/api/owners/#{URI.escape(owner.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/notifications"

    assert_equal 400, response.status
    assert_match "parameter 'type' is required", response.body
  end

  test "returns error for invalid notification type" do
    channel = channels(:verified)
    owner = channel.publisher

    post "/api/owners/#{URI.escape(owner.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/notifications?type=invalid_type"

    assert_equal 400, response.status
    assert_match "invalid", response.body
  end

  test "send email for valid notification type" do
    channel = channels(:verified)
    owner = channel.publisher

    assert_enqueued_emails 2 do
      post "/api/owners/#{URI.escape(owner.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/notifications?type=verified_no_wallet"
    end

    assert_equal 200, response.status
  end

  test "sends an verified_invalid_wallet notification to publisher" do
    channel = channels(:uphold_connected)
    owner = channel.publisher

    assert_enqueued_emails 2 do
      post "/api/owners/#{URI.escape(owner.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/notifications?type=verified_invalid_wallet"
    end
  end

  test "can create site channels from json" do
    owner = publishers(:small_media_group)

    new_channel_details = {
        "brave_publisher_id": "goodspud.com"
    }

    post "/api/owners/#{URI.escape(owner.owner_identifier)}/channels", as: :json, params: { channel: new_channel_details }

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert response_json["show_verification_status"]
    assert_equal "goodspud.com", response_json["id"]
  end

  test "created site channel has created_via_api flag set" do
    owner = publishers(:small_media_group)

    new_channel_details = {
        "brave_publisher_id": "goodspud.com"
    }

    post "/api/owners/#{URI.escape(owner.owner_identifier)}/channels", as: :json, params: { channel: new_channel_details }

    assert_equal 200, response.status
    channel = Channel.order(created_at: :asc).last
    assert channel.created_via_api?
  end
end

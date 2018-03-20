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

  test "verifies a channel" do
    channel = channels(:small_media_group_to_verify)
    publisher = channel.publisher

    payload = {
        verificationId: channel.id,
        token: channel.details.verification_token,
        verified: true,
        reason: ""
    }

    refute channel.verified
    patch "/api/owners/#{URI.escape(publisher.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/verifications", params: payload
    channel.reload
    assert channel.verified
    assert_equal 204, response.status
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

  test "requires an owner" do
    channel = channels(:small_media_group_to_verify)
    publisher = channel.publisher

    payload = {
        verificationId: channel.id,
        token: channel.details.verification_token,
        verified: true,
        reason: ""
    }

    refute channel.verified
    patch "/api/owners/#{URI.escape('publishers#uuid:aaaaaaaa-0000-0000-0000-000000000000')}/channels/#{URI.escape(channel.details.channel_identifier)}/verifications", params: payload
    assert_equal 404, response.status
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

require "test_helper"
require "shared/mailer_test_helper"

class Api::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "can get site channel by identifier" do
    channel = channels(:verified)

    get "/api/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_equal 200, response.status

    assert_match /#{channel.id}/, response.body
  end

  test "can get youtube channel by identifier" do
    channel = channels(:global_yt2)

    get "/api/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_equal 200, response.status

    assert_match /#{channel.id}/, response.body
  end

  test "can get owner's site channel by identifier" do
    channel = channels(:verified)
    publisher = channel.publisher

    get "/api/owners/#{URI.escape(publisher.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_equal 200, response.status

    assert_match /#{channel.id}/, response.body
  end

  test "show_verification_status returns as false if nil" do
    channel = channels(:google_verified)
    assert_nil channel.show_verification_status

    get "/api/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_equal(200, response.status)
    refute_nil JSON.parse(response.body)['show_verification_status']
  end

  test "show_verification_status returns as true if true" do
    channel = channels(:uphold_connected)
    assert channel.show_verification_status

    get "/api/channels/#{URI.escape(channel.details.channel_identifier)}"

    assert_equal(200, response.status)
    assert JSON.parse(response.body)['show_verification_status']
  end

  test "verifies a channel" do
    channel = channels(:small_media_group_to_verify)
    publisher = channel.publisher

    patch "/api/owners/#{URI.escape(publisher.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/verifications"

    assert_equal 204, response.status
  end

end

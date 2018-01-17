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

  test "verifies a channel" do
    channel = channels(:small_media_group_to_verify)
    publisher = channel.publisher

    patch "/api/owners/#{URI.escape(publisher.owner_identifier)}/channels/#{URI.escape(channel.details.channel_identifier)}/verifications"

    assert_equal 204, response.status
  end

end

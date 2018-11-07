require "test_helper"

class Api::V1::Stats::ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/stats/channels/:channel_id returns json representation of channel" do
    channel = channels(:stats_test)
    get "/api/v1/stats/channels/" + channel.id, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      assert_equal(
        {
          channel_id: channel.id,
          channel_identifier: "stats.test",
          channel_type: "website",
          name: "https://stats.test",
          stats: "{}",
          url: "https://stats.test",
          owner_id: channel.publisher.owner_identifier,
          created_at: channel.created_at.strftime("%Y-%m-%d %H:%M"),
          verified: true
        },
        JSON.parse(response.body).symbolize_keys
      )
  end

  test "youtube_channels_by_view_count returns an array of four arrays" do
    get "/api/v1/stats/channels/youtube_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)
    assert result.is_a?(Array)
    assert_equal result.length, 4
  end

  test "youtube_channels_by_view_count returns sorts channels into buckets by view count" do
    get "/api/v1/stats/channels/youtube_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)

    # ensure all view counts are within bucket_one range
    channel_ids_in_bucket_one = result.first
    channel_ids_in_bucket_one.each do |id|
      view_count = YoutubeChannelDetails.find(id).stats["view_count"]
      assert view_count >= 0
      assert view_count < 1000
    end

    channel_ids_in_bucket_two = result.second
    channel_ids_in_bucket_two.each do |id|
      view_count = YoutubeChannelDetails.find(id).stats["view_count"]
      assert view_count >= 1000
      assert view_count < 10000
    end

    channel_ids_in_bucket_three = result.third
    channel_ids_in_bucket_three.each do |id|
      view_count = YoutubeChannelDetails.find(id).stats["view_count"]
      assert view_count >= 10000
      assert view_count < 100000
    end

    channel_ids_in_bucket_four = result.fourth
    channel_ids_in_bucket_four.each do |id|
      view_count = YoutubeChannelDetails.find(id).stats["view_count"]
      assert view_count >= 100000
    end
  end

  test "twitch_channels_by_view_count returns sorts channels into buckets by view count" do
    get "/api/v1/stats/channels/twitch_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)

    # ensure all view counts are within bucket_one range
    channel_ids_in_bucket_one = result.first
    channel_ids_in_bucket_one.each do |id|
      view_count = TwitchChannelDetails.find(id).stats["view_count"]
      assert view_count >= 0
      assert view_count < 1000
    end

    channel_ids_in_bucket_two = result.second
    channel_ids_in_bucket_two.each do |id|
      view_count = TwitchChannelDetails.find(id).stats["view_count"]
      assert view_count >= 1000
      assert view_count < 10000
    end

    channel_ids_in_bucket_three = result.third
    channel_ids_in_bucket_three.each do |id|
      view_count = TwitchChannelDetails.find(id).stats["view_count"]
      assert view_count >= 10000
      assert view_count < 100000
    end

    channel_ids_in_bucket_four = result.fourth
    channel_ids_in_bucket_four.each do |id|
      view_count = TwitchChannelDetails.find(id).stats["view_count"]
      assert view_count >= 100000
    end
  end
end

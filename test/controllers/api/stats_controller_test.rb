require "test_helper"
require "shared/mailer_test_helper"

class Api::StatsControllerTest < ActionDispatch::IntegrationTest
  test "does signups per day and handles blanks" do
    publishers(:verified).update(created_at: 6.days.ago)
    publishers(:completed).update(created_at: 1.day.ago)

    get "/api/stats/signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    resp = JSON.parse(response.body)
    assert_equal resp, [
      [6.days.ago.to_date.to_s, 1],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, 21]
    ]

    get "/api/stats/email_verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    resp = JSON.parse(response.body)
    assert_equal resp, [
      [6.days.ago.to_date.to_s, 1],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, 20]
    ]
  end

  test "youtube_channels_by_view_count returns an array of four arrays" do
    get "/api/stats/youtube_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)
    assert result.is_a?(Array)
    assert_equal result.length, 4
  end

  test "youtube_channels_by_view_count returns sorts channels into buckets by view count" do
    get "/api/stats/youtube_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
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
    get "/api/stats/twitch_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
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

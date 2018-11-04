require "test_helper"
require "shared/mailer_test_helper"

class Api::V1::Stats::StatisticsControllerTest < ActionDispatch::IntegrationTest
  test "does signups per day and handles blanks" do
    publishers(:verified).update(created_at: 6.days.ago)
    publishers(:completed).update(created_at: 1.day.ago)

    get "/api/v1/stats/signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    resp = JSON.parse(response.body)


    assert_equal resp, [
      [6.days.ago.to_date.to_s, 1],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, 25]
    ]

    get "/api/v1/stats/email_verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    resp = JSON.parse(response.body)
    assert_equal resp, [
      [6.days.ago.to_date.to_s, 1],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, 24]
    ]
  end

  test "youtube_channels_by_view_count returns an array of four arrays" do
    get "/api/v1/stats/youtube_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)
    assert result.is_a?(Array)
    assert_equal result.length, 4
  end

  test "youtube_channels_by_view_count returns sorts channels into buckets by view count" do
    get "/api/v1/stats/youtube_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
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
    get "/api/v1/stats/twitch_channels_by_view_count", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
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

  test 'counts number of users with javascript enabled and disabled' do
    Publisher.update_all(last_sign_in_at: Time.now)
    get "/api/v1/stats/javascript_enabled_usage", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    assert_equal response.status, 200
    assert_equal response.body, {
      active_users_with_javascript_enabled: 0,
      active_users_with_javascript_disabled: Publisher.distinct.joins("inner join channels on channels.publisher_id = publishers.id").count
    }.to_json

    Publisher.joins("inner join channels on channels.publisher_id = publishers.id").last.update(javascript_last_detected_at: Time.now)

    get "/api/v1/stats/javascript_enabled_usage", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    assert_equal response.status, 200
    assert_equal response.body, {
      active_users_with_javascript_enabled: 1,
      active_users_with_javascript_disabled: Publisher.distinct.joins("inner join channels on channels.publisher_id = publishers.id").count - 1
    }.to_json
  end
end

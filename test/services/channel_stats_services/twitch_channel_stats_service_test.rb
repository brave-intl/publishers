require "test_helper"
require "webmock/minitest"

class TwitchChannelStatsServiceTest < ActiveJob::TestCase
  test "when offline returns true" do
    prev_offline = Rails.application.secrets[:api_twitch_base_uri]
    begin
      Rails.application.secrets[:api_twitch_base_uri] = nil

      twitch_channel_details = TwitchChannelDetails.first
      result = ChannelStatsServices::TwitchChannelStatsService.new(twitch_channel_details: twitch_channel_details).perform

      assert_equal true, result
    ensure
      Rails.application.secrets[:api_twitch_base_uri] = prev_offline
    end
  end

  test "updates the stats" do
    twitch_channel_details = TwitchChannelDetails.first

    assert_equal twitch_channel_details.stats["view_count"], 40000

    # stub view_count request
    view_count_response_json = {"data":[{"id":"198524994","login":"fakelogin","display_name":"fakelogin","view_count":40030}]}.to_json
    stub_request(:get, "#{Rails.application.secrets[:api_twitch_base_uri]}/users?login=#{URI.escape(twitch_channel_details.name)}")
      .to_return(status: 200, body: view_count_response_json)

    # stub follows_count request
    followers_count_response_json = {"total":8,"data":[],"pagination":{"cursor":"eyJiIjpudWxsLCJhIjoiIn0"}}.to_json
    stub_request(:get, "#{Rails.application.secrets[:api_twitch_base_uri]}/users/follows?to_id=198524994")
      .to_return(status: 200, body: followers_count_response_json)

    ChannelStatsServices::TwitchChannelStatsService.new(twitch_channel_details: twitch_channel_details).perform

    assert_equal twitch_channel_details.stats["view_count"], 40030
    assert_equal twitch_channel_details.stats["followers_count"], 8 
  end
end
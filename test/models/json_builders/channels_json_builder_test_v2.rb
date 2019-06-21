require 'test_helper'

class ChannelsJsonBuilderTestV2 < ActiveSupport::TestCase
    
  test "returns V2 Json" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilderV2.new.build)
    assert channels
  end

  test "each verified channel in V2 Json has an associated KYC'd Uphold Connection" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilderV2.new.build)
    verified_channels = []
    channels.each do |channel|
      verified_channels.push(channel) if channel[1]
    end
    verified_channels.each do |verified_channel|
      assert Channel.find_by_channel_identifier(verified_channel[0]).publisher.uphold_connection.is_member
    end
  end

  test "number of channels returned in V2 Json is at least as large as number of excluded channels" do
    require "publishers/excluded_channels"
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilderV2.new.build)
    assert channels.count >= @excluded_channel_ids.count
  end
end

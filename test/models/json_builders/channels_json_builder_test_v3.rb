require 'test_helper'
require "publishers/excluded_channels"

class ChannelsJsonBuilderTestV3 < ActiveSupport::TestCase
  let(:subject) { JSON.parse(JsonBuilders::ChannelsJsonBuilderV3.new.build) }

  describe "When a user has completed KYC" do
    it 'has their channel marked as verified' do
      identifier = channels(:uphold_connected_twitch_details).details.channel_identifier
      result = subject.detect { |x| x[0] == identifier }

      assert_equal "verified", result[1]
    end
  end
  describe "When a user has not completed KYC" do
    it 'has their channel marked as verified' do
      identifier = channels(:youtube_initial).details.channel_identifier
      result = subject.detect { |x| x[0] == identifier }

      assert_equal "connected", result[1]
    end
  end

  test "number of channels returned in V2 Json is at least as large as number of excluded channels" do
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilderV3.new.build)
    assert channels.count >= @excluded_channel_ids.count
  end
end

# typed: ignore
require "test_helper"
require "publishers/excluded_channels"

class ChannelsJsonBuilderTestV3P1 < ActiveSupport::TestCase
  let(:subject) { JSON.parse(JsonBuilders::ChannelsJsonBuilderV3P1.new.build) }

  describe "When a user enabled publisher ads" do
    it "their channel has publisher ads enabled" do
      identifier = channels(:global_verified).details.channel_identifier
      result = subject.detect { |x| x[0] == identifier }

      assert_equal true, result[3]
    end
  end

  test "number of channels returned in V3 Json is at least as large as number of excluded channels" do
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilderV3P1.new.build)
    assert channels.count >= @excluded_channel_ids.count
  end
end

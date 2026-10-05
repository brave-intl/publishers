# typed: false

require "test_helper"

class TwitchChannelTest < ActiveSupport::TestCase
  test "a channel cannot change twitch channel ids" do
    details = twitch_channel_details(:twitch_verified_details)
    assert details.valid?

    details.twitch_channel_id = "new_twitch_id"
    refute details.valid?
    assert_includes details.errors[:twitch_channel_id], "can not change once initialized"
  end

  test "requires a name" do
    details = twitch_channel_details(:twitch_verified_details)

    details.name = nil
    refute details.valid?
    assert details.errors[:name].present?
  end

  test "formats channel_identifier correctly" do
    details = twitch_channel_details(:twitch_verified_details)

    assert_equal "twitch#author:twtwtw2", details.channel_identifier
  end

  test "formats url correctly" do
    details = twitch_channel_details(:twitch_verified_details)

    assert_equal "https://twitch.tv/twtwtw2", details.url
  end
end

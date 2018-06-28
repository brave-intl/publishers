require "test_helper"

class YoutubeChannelTest < ActiveSupport::TestCase

  test "a channel cannot change youtube channel ids" do
    details = youtube_channel_details(:google_verified_details)
    assert details.valid?

    details.youtube_channel_id = "new_yt_id"
    refute details.valid?
  end

  test "formats channel_identifier correctly" do
    details = youtube_channel_details(:google_verified_details)

    assert_equal "youtube#channel:78032", details.channel_identifier
  end
end

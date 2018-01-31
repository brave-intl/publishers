require "test_helper"

class YoutubeChannelTest < ActiveSupport::TestCase

  test "a channel cannot change youtube channel ids" do
    details = youtube_channel_details(:google_verified_details)
    assert details.valid?

    details.youtube_channel_id = "new_yt_id"
    refute details.valid?
  end

  test "a channel cannot have the same youtube channel as another channel" do
    details = youtube_channel_details(:google_verified_details)
    assert details.valid?

    new_yt = YoutubeChannelDetails.new(youtube_channel_id: "sdffadsdfsa", title: "new title", thumbnail_url: "http://foo.com/a.jpg", auth_user_id: "1234 ")
    assert new_yt.valid?
    new_yt.youtube_channel_id = "78032"
    refute new_yt.valid?
  end

  test "formats channel_identifier correctly" do
    details = youtube_channel_details(:google_verified_details)

    assert_equal "youtube#channel:78032", details.channel_identifier
  end
end

require "test_helper"

class ChannelTest < ActiveSupport::TestCase

  test "site channel must have details" do
    channel = channels(:verified)
    assert channel.valid?

    assert_equal "verified.org", channel.details.brave_publisher_id
  end

  test "youtube channel must have details" do
    channel = channels(:google_verified)
    assert channel.valid?

    assert_equal "Some Other Guy's Channel", channel.details.title
  end

  test "channel can not change details" do
    channel = channels(:google_verified)
    assert channel.valid?

    channel.details = site_channel_details(:uphold_connected_details)
    refute channel.valid?

    assert_equal "can't be changed", channel.errors.messages[:details][0]
  end

  test "publication_title is the site domain for site publishers" do
    channel = channels(:verified)
    assert_equal 'verified.org', channel.details.brave_publisher_id
    assert_equal 'verified.org', channel.details.publication_title
    assert_equal 'verified.org', channel.publication_title
  end

  test "publication_title is the youtube channel title for youtube creators" do
    channel = channels(:youtube_new)
    assert_equal 'The DIY Channel', channel.details.title
    assert_equal 'The DIY Channel', channel.details.publication_title
    assert_equal 'The DIY Channel', channel.publication_title
  end

  test "can get all visible site channels" do
    assert_equal 2, publishers(:global_media_group).channels.visible_site_channels.length
  end

  test "can get all visible youtube channels" do
    assert_equal 2, publishers(:global_media_group).channels.visible_youtube_channels.length
  end

  test "can get all visible channels" do
    assert_equal 4, publishers(:global_media_group).channels.visible.length
  end

  test "can get all verified channels" do
    assert_equal 3, publishers(:global_media_group).channels.verified.length
  end
end

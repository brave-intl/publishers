require 'test_helper'

class CleanAbandonedSiteChannelsJobTest < ActiveJob::TestCase
  test "cleans non-visible (abandoned) site channels older than one day" do
    publisher = publishers(:medium_media_group)

    assert SiteChannelDetails.find_by(brave_publisher_id: "medium_2.org")

    assert_difference("Channel.count", -1 * Channel.not_visible_site_channels.count) do
      assert_difference("publisher.channels.count", -1 ) do
        CleanAbandonedSiteChannelsJob.perform_now
      end
    end

    refute SiteChannelDetails.find_by(brave_publisher_id: "medium_2.org")
  end

  test "cleans non-visible (abandoned) site channel details older than one day" do
    assert SiteChannelDetails.find_by(brave_publisher_id: "medium_2.org")

    assert_difference("SiteChannelDetails.count", -1 * Channel.not_visible_site_channels.count) do
      CleanAbandonedSiteChannelsJob.perform_now
    end

    refute SiteChannelDetails.find_by(brave_publisher_id: "medium_2.org")
  end
end

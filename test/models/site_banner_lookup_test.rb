require "test_helper"

class SiteBannerLookupTest < ActionDispatch::IntegrationTest
  test "creates a site banner lookup" do
    channel = channels(:verified)
    channel.send(:update_site_banner_lookup!)
    assert_equal channel.site_banner_lookup.channel_identifier, channel.details.channel_identifier
  end

  test "if a site banner gets updated, the lookup gets updated too" do
    new_title = "I destroyed the stones with the stones"
    channel = channels(:verified)
    channel.site_banner.update(title: new_title)
    assert_equal new_title, channel.site_banner_lookup.derived_site_banner_info['title']
  end

  test "make sure SBL has the right wallet status" do

  end
end

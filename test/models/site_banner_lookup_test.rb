require "test_helper"

class SiteBannerLookupTest < ActionDispatch::IntegrationTest
  test "creates a site banner lookup" do
    channel = channels(:verified)
    channel.send(:update_sha2_lookup)
    assert_equal channel.site_banner_lookup.channel_identifier, channel.details.channel_identifier
  end

  test "if a site banner gets updated, the lookup gets updated too" do

  end

  test "make sure SBL has the right wallet status" do

  end
end

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

  test "make sure site_banner_lookup has the right wallet status" do
    uphold_connection = uphold_connections(:verified_connection)
    uphold_connection.update(is_member: false)
    uphold_connection.address = "12345678-0000-0000-0000-abcd00000000"
    uphold_connection.update(is_member: true)
    assert_equal uphold_connection.address, uphold_connection.publisher.channels.first.site_banner_lookup.wallet_address
  end
end

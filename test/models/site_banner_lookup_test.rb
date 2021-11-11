# typed: false
require "test_helper"

class SiteBannerLookupTest < ActionDispatch::IntegrationTest
  test "creates a site banner lookup" do
    channel = channels(:verified)
    channel.send(:update_site_banner_lookup!)
    assert_equal channel.site_banner_lookup.channel_identifier, channel.details.channel_identifier
  end

  test "make sure default site banner mode gets respected" do
    new_title = "I destroyed the stones with the stones"
    default_mode_channel = channels(:verified)
    original_title = site_banners(:verified_default_banner).title
    default_mode_channel.site_banner.update(title: new_title)

    # Check to make sure the title for default mode didn't get changed
    assert_equal original_title, default_mode_channel.site_banner_lookup.derived_site_banner_info["title"]

    # Check to make sure new title didn't overwrite the default value
    assert_not_equal new_title, default_mode_channel.publisher.default_site_banner.title

    normal_channel = channels(:completed)
    normal_channel.site_banner.update(title: new_title)
    assert_equal new_title, normal_channel.site_banner_lookup.derived_site_banner_info["title"]
  end

  test "make sure site_banner_lookup has the right wallet status" do
    uphold_connection = uphold_connections(:verified_connection)
    uphold_connection.update(is_member: false)
    uphold_connection.address = "12345678-0000-0000-0000-abcd00000000"
    uphold_connection.update(is_member: true)
    assert_equal uphold_connection.address, uphold_connection.publisher.channels.first.site_banner_lookup.wallet_address
  end
end

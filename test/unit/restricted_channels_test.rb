require "test_helper"
require "publishers/restricted_channels"

class RestrictedChannelsTest < ActiveSupport::TestCase
  test "restricted_brave_publisher_id? for restricted" do
    assert Publishers::RestrictedChannels.restricted_brave_publisher_id?("google.com")
  end

  test "restricted_brave_publisher_id? for unrestricted" do
    refute Publishers::RestrictedChannels.restricted_brave_publisher_id?("tomatoland.org")
  end

  test "restricted? for restricted site Channel" do
    c = channels(:to_verify_restricted)
    assert Publishers::RestrictedChannels.restricted?(c)
  end

  test "restricted? for unrestricted site Channel" do
    c = channels(:to_verify_dns)
    refute Publishers::RestrictedChannels.restricted?(c)
  end

  test "restricted? for restricted SiteChannelDetails" do
    d = site_channel_details(:to_verify_restricted_details)
    assert Publishers::RestrictedChannels.restricted?(d)
  end

  test "restricted? for unrestricted SiteChannelDetails" do
    d = site_channel_details(:to_verify_details)
    refute Publishers::RestrictedChannels.restricted?(d)
  end
end
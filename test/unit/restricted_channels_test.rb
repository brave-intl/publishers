require "test_helper"
require "publishers/restricted_channels"

class RestrictedChannelsTest < ActiveSupport::TestCase
  test "restricted brave_publisher_id" do
    assert Publishers::RestrictedChannels.restricted_brave_publisher_id?("google.com")
  end

  test "unrestricted brave_publisher_id" do
    refute Publishers::RestrictedChannels.restricted_brave_publisher_id?("tomatoland.org")
  end
end
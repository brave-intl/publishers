require "test_helper"
require "publishers/excluded_channels"

class ExcludedChannelsTest < ActiveSupport::TestCase
  test "excluded_brave_publisher_id? for excluded" do
    assert Publishers::ExcludedChannels.excluded_brave_publisher_id?("google.com")
  end

  test "excluded_brave_publisher_id? for unexcluded" do
    refute Publishers::ExcludedChannels.excluded_brave_publisher_id?("tomatoland.org")
  end

  test "excluded? for excluded site Channel" do
    c = channels(:to_verify_restricted)
    assert Publishers::ExcludedChannels.excluded?(c)
  end

  test "restricted? for unrestricted site Channel" do
    c = channels(:to_verify_dns)
    refute Publishers::ExcludedChannels.excluded?(c)
  end
end

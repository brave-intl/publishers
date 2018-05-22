require "test_helper"
require "publishers/excluded_channels"

class ExcludedChannelsTest < ActiveSupport::TestCase
  test "excluded_brave_publisher_id? for excluded" do
    assert Publishers::ExcludedChannels.excluded_brave_publisher_id?("google.com")
  end

  test "excluded_brave_publisher_id? for unexcluded" do
    refute Publishers::ExcludedChannels.excluded_brave_publisher_id?("tomatoland.org")
  end
end

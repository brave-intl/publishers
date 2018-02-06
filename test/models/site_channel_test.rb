require "test_helper"

class SiteChannelTest < ActiveSupport::TestCase

  test "a channel cannot change brave_publisher_id" do
    details = site_channel_details(:verified_details)
    assert details.valid?

    details.brave_publisher_id = "foo.com"
    refute details.valid?
  end

  test "a channel cannot have the same brave_publisher_id as another verified channel" do
    details = site_channel_details(:verified_details)
    assert details.valid?

    # Does not exist
    new_details = SiteChannelDetails.new(brave_publisher_id: "sdffadsdfsa.com")
    assert new_details.valid?

    # Exists, but not verified
    new_details = SiteChannelDetails.new(brave_publisher_id: "default.org")
    assert new_details.valid?

    # Exists and is verified
    new_details = SiteChannelDetails.new(brave_publisher_id: "verified.org")
    refute new_details.valid?
  end

  test "a site channel assigned a brave_publisher_id_error_code and brave_publisher_id will not be valid" do
    details = SiteChannelDetails.new
    assert details.valid?

    details.brave_publisher_id = 'asdf asdf'
    details.brave_publisher_id_error_code = :invalid_uri

    refute details.valid?
    assert_equal [:"brave_publisher_id_unnormalized"], details.errors.keys
    assert_equal "invalid_uri", details.brave_publisher_id_error_code
    assert_equal I18n.t("activerecord.errors.models.site_channel_details.attributes.brave_publisher_id.invalid_uri"), details.brave_publisher_id_error_description
  end

  test "a site channel assigned a brave_publisher_id_error_code and brave_publisher_id_unnormalized will not be valid" do
    details = SiteChannelDetails.new
    details.brave_publisher_id_unnormalized = 'asdf asdf'
    assert details.save

    details.brave_publisher_id_error_code = :invalid_uri

    refute details.valid?
    assert_equal [:brave_publisher_id_unnormalized], details.errors.keys
    assert_equal "invalid_uri", details.brave_publisher_id_error_code
    assert_equal I18n.t("activerecord.errors.models.site_channel_details.attributes.brave_publisher_id.invalid_uri"), details.brave_publisher_id_error_description
  end

  test "recent unverified site_channels can be found" do

    brave_publisher_ids = SiteChannelDetails.recent_unverified_site_channels(max_age: 12.weeks).pluck(:brave_publisher_id)

    assert_equal 6, brave_publisher_ids.length
    assert brave_publisher_ids.include?("stale.org")

    # Default max_age of 6 weeks
    brave_publisher_ids = SiteChannelDetails.recent_unverified_site_channels.pluck(:brave_publisher_id)

    assert_equal 5, brave_publisher_ids.length
    refute brave_publisher_ids.include?("stale.org")
  end

end

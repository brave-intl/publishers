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

  test "a channel can have blank verification_method" do
    details = site_channel_details(:new_site_details)
    assert details.verification_method.blank?
    assert details.valid?
  end

  test "a channel with verification_method must be well formed" do
    details = site_channel_details(:new_site_details)
    SiteChannelDetails::VERIFICATION_METHODS.each do |m|
      details.verification_method = m
      assert details.valid?
    end
    details.verification_method = "potato"
    refute details.valid?
  end

  test "a channel can have blank verification_token" do
    details = site_channel_details(:new_site_details)
    assert details.verification_token.blank?
    assert details.valid?
  end

  test "a channel with verification_token must be well formed" do
    details = site_channel_details(:new_site_details)
    details.verification_token = "6d660f14752f460b59dc62907bfe3ae1cb4727ae0645de74493d99bcf63ddb94"
    assert details.valid?

    details.verification_token = "short"
    refute details.valid?

    details.verification_token = "longlonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglong"
    refute details.valid?

    details.verification_token = "funny?!"
    refute details.valid?
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

    assert_equal 16, brave_publisher_ids.length
    assert brave_publisher_ids.include?("stale.org")

    # Default max_age of 6 weeks
    brave_publisher_ids = SiteChannelDetails.recent_unverified_site_channels.pluck(:brave_publisher_id)

    assert_equal 15, brave_publisher_ids.length
    refute brave_publisher_ids.include?("stale.org")
  end

  test "recent unverified site_channels ready to verify can be found" do
    sites = SiteChannelDetails.recent_ready_to_verify_site_channels(max_age: 6.weeks)
    sites.each do |site|
      refute site.channel.verified?
      refute site.verification_method.nil?
      assert site.updated_at > Time.now - 6.weeks # Updated within the last 6 weeks
    end
  end
end

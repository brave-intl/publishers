require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "site channel must have details" do
    channel = channels(:verified)
    assert channel.valid?

    assert_equal "verified.org", channel.details.brave_publisher_id
  end

  test "youtube channel must have details" do
    channel = channels(:google_verified)
    assert channel.valid?

    assert_equal "Some Other Guy's Channel", channel.details.title
  end

  test "channel can not change details" do
    channel = channels(:google_verified)
    assert channel.valid?

    channel.details = site_channel_details(:uphold_connected_details)
    refute channel.valid?

    assert_equal "can't be changed", channel.errors.messages[:details][0]
  end

  test "publication_title is the site domain for site publishers" do
    channel = channels(:verified)
    assert_equal 'verified.org', channel.details.brave_publisher_id
    assert_equal 'verified.org', channel.details.publication_title
    assert_equal 'verified.org', channel.publication_title
  end

  test "publication_title is the youtube channel title for youtube creators" do
    channel = channels(:youtube_new)
    assert_equal 'The DIY Channel', channel.details.title
    assert_equal 'The DIY Channel', channel.details.publication_title
    assert_equal 'The DIY Channel', channel.publication_title
  end

  test "can get all visible site channels" do
    assert_equal 2, publishers(:global_media_group).channels.visible_site_channels.length
  end

  test "can get all visible youtube channels" do
    assert_equal 2, publishers(:global_media_group).channels.visible_youtube_channels.length
  end

  test "can get all visible channels" do
    assert_equal 4, publishers(:global_media_group).channels.visible.length
  end

  test "can get all verified channels" do
    assert_equal 3, publishers(:global_media_group).channels.verified.length
  end

  # Maybe put this in a RegisterChannelForPromoJobTest?
  test "verifying a channel calls register_channel_for_promo (site)" do
    channel = channels(:default)
    publisher = channel.publisher
    publisher.promo_enabled_2018q1 = true
    publisher.save!

    # verify RegisterChannelForPromoJob is called
    channel.verified = true
    assert_enqueued_jobs(1) do
      channel.save!
    end

    # verify it worked and the channel has a referral code
    assert channel.promo_registration.referral_code

    # verify nothing happens if verified_changed? to false, or to true but not saved
    assert_enqueued_jobs(0) do
      channel.verified = false
      channel.save!
      channel.verified = true
    end
  end

  test "verifying a channel calls register_channel_for_promo (youtube)" do
    # To 'verify' a new youtube channel, we delete a previously verified channel then instantiate it
    channel_original = channels(:google_verified)
    publisher = channel_original.publisher

    # grab the details first, then destroy the original
    channel_details_copy = channel_original.details.dup
    channel_original.destroy!

    publisher.promo_enabled_2018q1 = true
    publisher.save!

    # check that RegisterChannelForPromoJob is called when it is verified
    # channel_copy.verified = true
    channel_copy = Channel.new(details: channel_details_copy, verified: true, publisher: publisher)
    assert_enqueued_jobs(1) do
      channel_copy.save!
    end

    assert channel_copy.promo_registration.referral_code
  end
end

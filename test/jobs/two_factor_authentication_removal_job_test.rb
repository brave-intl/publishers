# typed: false

require "test_helper"

class TwoFactorAuthenticationRemovalJobTest < ActiveJob::TestCase
  test "Does not remove publisher's 2fa until timeout period has passed" do
    publisher = publishers(:verified_totp_only)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_not_nil(publisher.totp_registration)
  end

  test "Removes selected wallet" do
    publisher = publishers(:uphold_connected)

    assert publisher.selected_wallet_provider

    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)
    TwoFactorAuthenticationRemovalJob.perform_now

    refute publisher.reload.selected_wallet_provider
  end

  test "Removes publisher's 2fa when timeout period has passed" do
    publisher = publishers(:uphold_connected)
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_nil(publisher.totp_registration)
  end

  test "Sets publisher's 2fa status back to what it was originally" do
    publisher = publishers(:suspended)

    publisher.status_updates.create(status: PublisherStatusUpdate::LOCKED)
    assert_equal(publisher.last_status_update.status, PublisherStatusUpdate::LOCKED)

    two_factor_authentication_removal = two_factor_authentication_removals(:suspended_2fa_removal)

    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)

    TwoFactorAuthenticationRemovalJob.perform_now
    assert_nil(publisher.totp_registration)
    publisher.last_status_update.reload
    assert_equal(publisher.last_status_update.status, PublisherStatusUpdate::SUSPENDED)
  end

  test "Removes publisher's channels when timeout period has passed" do
    publisher = publishers(:uphold_connected)
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_empty(publisher.channels)
  end

  test "Does not remove publisher's channels more than once" do
    publisher = publishers(:uphold_connected)
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    channel = channels(:google_verified)
    channel_details = channel.details.dup

    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)

    # First try channels are removed
    Channel.create!(details: channel_details, verified: true, publisher: publisher)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_empty(publisher.channels)

    # Subsequent tries, channels are not removed
    Channel.create!(details: channel_details, verified: true, publisher: publisher)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_not_empty(publisher.channels)
  end
end

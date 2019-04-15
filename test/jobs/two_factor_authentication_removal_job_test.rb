require "test_helper"

class TwoFactorAuthenticationRemovalJobTest < ActiveJob::TestCase
  test "Does not remove publisher's 2fa until timeout period has passed" do
    publisher = publishers(:verified)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_not_nil(publisher.totp_registration)
  end

  test "Removes publisher's 2fa when timeout period has passed" do
    publisher = publishers(:verified)
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_nil(publisher.totp_registration)
  end

  test "Removes publisher's channels when timeout period has passed" do
    publisher = publishers(:verified)
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)
    TwoFactorAuthenticationRemovalJob.perform_now
    assert_empty(publisher.channels)
  end

  test "Does not remove publisher's channels more than once" do
    publisher = publishers(:verified)
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

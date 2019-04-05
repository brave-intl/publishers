require "test_helper"

class TwoFactorAuthenticationRemovalTest < ActiveSupport::TestCase
  test "Two factor removal takes 14 days" do
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    remainder = two_factor_authentication_removal.two_factor_authentication_removal_days_remaining
    assert_equal("14 days", remainder)
  end

  test "Locked state doesn't being until 2fa removal is complete" do
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    remainder = two_factor_authentication_removal.locked_status_days_remaining
    assert_equal("Not started yet", remainder)
  end

  test "Locked state begins once 2fa removal is complete" do
    two_factor_authentication_removal = two_factor_authentication_removals(:one)
    original_date = two_factor_authentication_removal.created_at
    advanced_date = original_date - 14.days
    two_factor_authentication_removal.update(created_at: advanced_date)
    remainder = two_factor_authentication_removal.locked_status_days_remaining
    assert_equal("about 1 month", remainder)
  end
end

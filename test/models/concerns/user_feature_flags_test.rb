# typed: false

require "test_helper"

class UserFeatureFlagsTest < ActiveSupport::TestCase
  it "would successfully read the previous values for promo stats" do
    publisher = publishers(:default)
    assert_not publisher.has_daily_emails_for_promo_stats?
    assert_empty Publisher.daily_emails_for_promo_stats

    publisher.update_feature_flags_from_form({UserFeatureFlags::DAILY_EMAILS_FOR_PROMO_STATS => UserFeatureFlags::DISABLED})
    assert_not publisher.has_daily_emails_for_promo_stats?
    assert_empty Publisher.daily_emails_for_promo_stats

    publisher.update_feature_flags_from_form({UserFeatureFlags::DAILY_EMAILS_FOR_PROMO_STATS => UserFeatureFlags::PREVIOUS_DAY})
    assert publisher.has_daily_emails_for_promo_stats?
    assert_not_empty Publisher.daily_emails_for_promo_stats
    publisher.update_feature_flags_from_form({UserFeatureFlags::DAILY_EMAILS_FOR_PROMO_STATS => "true"}) # previous value
    assert publisher.has_daily_emails_for_promo_stats?
    assert_not_empty Publisher.daily_emails_for_promo_stats

    publisher.update_feature_flags_from_form({UserFeatureFlags::DAILY_EMAILS_FOR_PROMO_STATS => UserFeatureFlags::MONTH_TO_DATE})
    assert publisher.receives_mtd_promo_emails?
    assert_not_empty Publisher.daily_emails_for_promo_stats
  end
end

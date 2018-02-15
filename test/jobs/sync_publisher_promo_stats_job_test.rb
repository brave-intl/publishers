require 'test_helper'

class SyncPublisherPromoStatsJobTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "updates stats" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_equal publisher.promo_stats_2018q1, {} # sanity check

    # enable promo and register channel
    post promo_registrations_path

    SyncPublisherPromoStatsJob.perform_now
    publisher.reload

    assert_not_equal publisher.promo_stats_2018q1, {}
  end
end
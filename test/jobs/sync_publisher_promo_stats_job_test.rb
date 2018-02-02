require 'test_helper'

class SyncPublisherPromoStatsJobTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "updates stats" do
    publisher = publishers(:completed)
    sign_in publisher

    # enable promo and register channel
    post promo_registrations_path

    assert_difference -> {Publisher.where.not(promo_stats_2018q1: "{}").count}, 1 do
      SyncPublisherPromoStatsJob.perform_now
    end
  end
end
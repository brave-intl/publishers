require 'test_helper'

class Sync::PublisherPromoStatsJobTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper
  
  test "updates stats for all publishers" do
    publisher_one = publishers(:completed)
    publisher_two = publishers(:global_media_group)

    enable_promo_for_publisher(publisher_one)
    enable_promo_for_publisher(publisher_two)

    Sync::PublisherPromoStatsJob.perform_now

    publisher_one.reload
    publisher_two.reload

    assert_not_equal publisher_one.promo_stats_2018q1, {}
    assert_not_equal publisher_two.promo_stats_2018q1, {}
  end

  test "test updates stats for a single publisher" do
    publisher_one = publishers(:completed)
    publisher_two = publishers(:global_media_group)

    enable_promo_for_publisher(publisher_one)
    enable_promo_for_publisher(publisher_two)

    Sync::PublisherPromoStatsJob.perform_now(publisher_id: publisher_one.id)

    publisher_one.reload
    publisher_two.reload

    assert_not_equal publisher_one.promo_stats_2018q1, {}
    assert_equal publisher_two.promo_stats_2018q1, {}
  end

  private

  # Requires a verified publisher
  def enable_promo_for_publisher(publisher)
    sign_in publisher
    assert_equal publisher.promo_stats_2018q1, {} # sanity check
    post promo_registrations_path
  end
end
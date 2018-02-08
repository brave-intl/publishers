require "test_helper"
require "webmock/minitest"

class PublisherPromoStatsFetcherTest <  ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PromosHelper

  test "fetcher successfully saves first stats and stats_updated_at, does not update if stats delay has not passed" do
    publisher = publishers(:completed)
    sign_in publisher

    # enable promo and register channel
    post promo_registrations_path

    PublisherPromoStatsFetcher.new(publisher: publisher).perform

    # verify the stats have been received and saved
    assert_not_equal publisher.promo_stats_2018q1, "{}"
    
    # verify stats_updated_at has been set
    assert_not_nil publisher.promo_stats_updated_at_2018q1

    first_stats = publisher.promo_stats_2018q1
    first_stats_updated_at = publisher.promo_stats_updated_at_2018q1    

    # verify that stats and stats_updated at are not changed under threshold
    travel Publisher::PROMO_STATS_UPDATE_DELAY - 1.minute do
      PublisherPromoStatsFetcher.new(publisher: publisher).perform
      assert_equal publisher.promo_stats_2018q1, first_stats
      assert_equal publisher.promo_stats_updated_at_2018q1, first_stats_updated_at
    end
  end

  test "fetcher successfully updates stats and stats_updated_at" do
    publisher = publishers(:completed)
    sign_in publisher

    # enable promo and register channel
    post promo_registrations_path
    
    # set stats for the first time
    PublisherPromoStatsFetcher.new(publisher: publisher).perform
    first_stats = publisher.promo_stats_2018q1
    first_stats_updated_at = publisher.promo_stats_updated_at_2018q1

    # verify stats are updated
    travel Publisher::PROMO_STATS_UPDATE_DELAY + 1.second do
      PublisherPromoStatsFetcher.new(publisher: publisher).perform
      assert_not_equal publisher.promo_stats_2018q1, first_stats
      assert_not_equal publisher.promo_stats_updated_at_2018q1, first_stats_updated_at
    end
  end

  test "nothing changed saved if publisher has not enabled" do
    publisher = publishers(:completed)
    
    PublisherPromoStatsFetcher.new(publisher: publisher).perform

    # verify the stats have not been changed
    assert_equal publisher.promo_stats_2018q1, {}
    
    # verify stats_updated_at has not been set
    assert_nil publisher.promo_stats_updated_at_2018q1
  end

  test "nothing changed if a publisher has enabled promo but has no verified channels" do
    publisher = publishers(:default)
    sign_in publisher

    post promo_registrations_path
    
    PublisherPromoStatsFetcher.new(publisher: publisher).perform

    # verify the stats have not been changed
    assert_equal publisher.promo_stats_2018q1, {}
    
    # verify stats_updated_at has not been set
    assert_nil publisher.promo_stats_updated_at_2018q1
  end
end
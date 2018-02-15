require 'test_helper'

class PromosHelperTest < ActionView::TestCase
  test "total_possible_referrals returns 0 for promo disabled publisher" do
    publisher = publishers(:completed)
    total_possible_referrals = total_possible_referrals(publisher)
    assert_equal total_possible_referrals, 0
  end

  test "total_possible_referrals returns correct number of downloads for only one time period" do
    publisher = publishers(:completed)
    publisher.promo_stats_2018q1 = {"times"=>[Time.now.to_s], "series"=>{"name"=>"downloads", "values"=>[100]}}
    publisher.save

    total_possible_referrals = total_possible_referrals(publisher)
    assert_equal total_possible_referrals, 100
  end

  test "total_possible_referrals returns correct number of downloads for many time periods" do
    publisher = publishers(:completed)
    publisher.promo_stats_2018q1 = {"times"=>[Time.now.to_s], "series"=>{"name"=>"downloads", "values"=>[100, 10, 0, 20]}}
    publisher.save

    total_possible_referrals = total_possible_referrals(publisher)
    assert_equal total_possible_referrals, 130
  end
end

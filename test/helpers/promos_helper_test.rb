require 'test_helper'
class PromosHelperTest < ActionView::TestCase
  test "returns correct number of promo stats " do
    publisher = publishers(:completed)
    publisher.promo_stats_2018q1 = offline_promo_stats
    publisher.save!

    total_referral_downloads = total_referral_downloads(publisher)
    assert_equal total_referral_downloads, 200
    
    confirmed_referral_downloads = confirmed_referral_downloads(publisher)
    assert_equal confirmed_referral_downloads, 30
  end

  test "if aggregate downloads or finalized is nil, display 0" do
    publisher = publishers(:completed)
    publisher.promo_stats_2018q1 = {"times"=>[], "series"=>{"name"=>"downloads", "values"=>[]}, "aggregate"=>{"downloads"=>nil, "finalized"=>nil}}
    publisher.save!

    total_referral_downloads = total_referral_downloads(publisher)
    assert_equal total_referral_downloads, 0
    
    confirmed_referral_downloads = confirmed_referral_downloads(publisher)
    assert_equal confirmed_referral_downloads, 0
  end
end

require "test_helper"

class SiteBannerTest < ActiveSupport::TestCase
  test "SiteBanner presence tests" do
    publisher = publishers(:completed)

    site_banner = SiteBanner.new(title: "Hello", publisher: publisher)
    assert_not site_banner.save

    site_banner.description = "World"
    assert_not site_banner.save

    site_banner.donation_amounts = [1,5,10]
    assert_not site_banner.save

    site_banner.default_donation = 5
    assert site_banner.save
  end

  test "Donation amounts are valid" do
    publisher = publishers(:completed)
    site_banner = SiteBanner.new(title: "Hello", publisher: publisher, description: "World", default_donation: 5)
    assert_not site_banner.save
    site_banner.donation_amounts = [-1, 5, 10]
    assert_not site_banner.save
    site_banner.donation_amounts = [1, 2, 3, 5]
    assert_not site_banner.save
    site_banner.donation_amounts = [1, 2]
    assert_not site_banner.save
    site_banner.donation_amounts = [0, 1, 2]
    assert_not site_banner.save
    site_banner.donation_amounts = [1, 10, 100]
    assert_not site_banner.save
    site_banner.donation_amounts = [1, 5, 10]
    assert site_banner.save
  end
end

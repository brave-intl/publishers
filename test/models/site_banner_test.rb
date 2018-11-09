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
    site_banner.donation_amounts = [1, 10, 1000]
    assert_not site_banner.save
    site_banner.donation_amounts = [1, 5, 10]
    assert site_banner.save
  end

  test "Social links are valid" do
    publisher = publishers(:completed)
    site_banner = SiteBanner.new(
      title: "Hello",
      publisher: publisher,
      description: "World",
      default_donation: 5,
      donation_amounts: [1, 5, 10]
    )
    site_banner.social_links = {"youku": "abcd"}
    site_banner.save
    assert site_banner.social_links.blank?

    # Test for youtube
    site_banner.social_links = {"youtube": "http://example.com"}
    site_banner.save
    assert site_banner.social_links["youtube"].blank?

    site_banner.social_links = {"youtube": "https://youtube.com/user/DrDisRespect"}
    site_banner.save
    assert site_banner.social_links["youtube"] == "https://youtube.com/user/DrDisRespect"

    # Test for twitch
    site_banner.social_links = {"twitch": "http://example.com"}
    site_banner.save
    assert site_banner.social_links["twitch"].blank?
    ["https://twitch.tv/shroud", "https://www.twitch.tv/shroud"].each do |twitch_link|
      site_banner.social_links = {"twitch": twitch_link}
      site_banner.save
      assert site_banner.social_links["twitch"] == twitch_link
    end

    # Test for twitter
    site_banner.social_links = {"twitter": "https://tw.tr/brave"}
    site_banner.save
    assert site_banner.social_links["twitter"].blank?
    ["https://twitter.com/brave", "https://www.twitter.com/brave"].each do |twitter_link|
      site_banner.social_links = {"twitter": twitter_link}
      site_banner.save
      assert site_banner.social_links["twitter"] == twitter_link
    end
  end
end

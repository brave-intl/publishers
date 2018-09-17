require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PublishersHelper

  test "publisher saves a site banner and the data is consistent" do
    publisher = publishers(:completed)
    sign_in publisher

    get home_publishers_path
    assert_response :success

    post(publisher_site_banners_path(publisher),
      params: {
        title: "Hello World",
        description: "Lorem Ipsum",
        donation_amounts: "[5, 10, 15]",
      }
    )

    assert_response :success
    publisher.reload
    assert_equal publisher.site_banner, SiteBanner.last
  end
end

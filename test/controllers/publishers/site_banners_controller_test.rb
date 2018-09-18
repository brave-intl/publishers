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

  test "publisher cannot upload an excessively large file" do
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

    fake_data = "A" * Publishers::SiteBannersController::MAX_IMAGE_SIZE
    post(update_logo_publisher_site_banners_path, params: {image: "data:image/jpeg;base64," + fake_data})

    publisher.reload
    assert_nil publisher.site_banner.logo.attachment
  end

  test "publisher can upload a normally sized file" do
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

    fake_data = "A" * (Publishers::SiteBannersController::MAX_IMAGE_SIZE / 10)
    post(update_logo_publisher_site_banners_path, params: {image: "data:image/jpeg;base64," + fake_data})

    publisher.reload
    assert_not_nil publisher.site_banner.logo
  end
end

require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PublishersHelper

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "publisher not part of the whitelist can't upload" do
    publisher = publishers(:completed)
    Rails.application.secrets[:brave_rewards_email_whitelist] = ""
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

    assert_response :unauthorized
  end

  test "publisher saves a site banner and the data is consistent" do
    publisher = publishers(:completed)
    Rails.application.secrets[:brave_rewards_email_whitelist] = publisher.email
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
    Rails.application.secrets[:brave_rewards_email_whitelist] = publisher.email
    sign_in publisher

    get home_publishers_path
    assert_response :success

    site_banner = site_banners(:completed)

    fake_data = "A" * Publishers::SiteBannersController::MAX_IMAGE_SIZE
    post(update_logo_publisher_site_banners_path(publisher.id), params: {image: "data:image/jpeg;base64," + fake_data})

    publisher.reload
    assert_nil publisher.site_banner.logo.attachment
  end

  test "publisher can upload a normally sized file" do
    publisher = publishers(:completed)
    Rails.application.secrets[:brave_rewards_email_whitelist] = publisher.email
    sign_in publisher

    get home_publishers_path
    assert_response :success

    site_banner = site_banners(:completed)

    source_image_path = "./app/assets/images/brave-lion@3x.jpg"
    fake_data = Base64.encode64(open(source_image_path) { |io| io.read })
    post(update_logo_publisher_site_banners_path(publisher.id), params: {image: "data:image/jpeg;base64," + fake_data})

    publisher.reload
    assert_not_nil publisher.site_banner.logo.attachment
  end
end

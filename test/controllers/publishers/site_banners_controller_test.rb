require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PublishersHelper

  test "Creating a new banner will return default values" do
      publisher = publishers(:default)
      sign_in publisher

      # Fetch returns new banner if one doesn't exist yet.
      get '/publishers/' + publisher.id + "/site_banners/fetch?channel_id=00000000-0000-0000-0000-000000000000", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      new_banner = JSON.parse(response.body)

      assert_response :success
      assert_equal("Brave Rewards", new_banner["title"])
      assert_equal([1, 5, 10], new_banner["donationAmounts"])
      assert_equal(false, new_banner["default"])
      assert_equal("00000000-0000-0000-0000-000000000000", new_banner["channel_id"])
      publisher.reload
  end

  test "Reading an existing banner will return existing values" do
      publisher = publishers(:default)
      sign_in publisher

      get '/publishers/' + publisher.id + "/site_banners/fetch?channel_id=00000000-0000-0000-0000-000000000001", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      existing_banner = JSON.parse(response.body)

      assert_response :success
      assert_equal("Hello World", existing_banner["title"])
      assert_equal([1, 5, 10], existing_banner["donationAmounts"])
      assert_equal(true, existing_banner["default"])
      assert_equal("00000000-0000-0000-0000-000000000001", existing_banner["channel_id"])
      publisher.reload
  end

  test "Updating a banner with valid data will return 200" do
      publisher = publishers(:default)
      sign_in publisher

      post '/publishers/' + publisher.id + "/site_banners/save?channel_id=00000000-0000-0000-0000-000000000001",
      headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" },
      params: {title: "Hello World", description: "Lorem Ipsum", donation_amounts: [5, 10, 15].to_json, default: false}

      assert_response :success
  end

  test "Users cannot have more than one default banner" do
      publisher = publishers(:default)
      sign_in publisher

      post '/publishers/' + publisher.id + "/site_banners/save?channel_id=00000000-0000-0000-0000-000000000002",
      headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" },
      params: {title: "Hello World", description: "Lorem Ipsum", donation_amounts: [5, 10, 15].to_json, default: true}

      assert_not(publisher.site_banners.find_by(channel_id: "00000000-0000-0000-0000-000000000002").default)
  end

  test "GET on /channels returns ids, names, and types of user's chnanels" do
      publisher = publishers(:default)
      sign_in publisher

      get '/publishers/' + publisher.id + "/site_banners/channels", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      channels = JSON.parse(response.body)["channels"]
      assert_not_nil(channels[0]["id"])
      assert_not_nil(channels[0]["name"])
      assert_not_nil(channels[0]["type"])
  end

  test "publisher cannot upload an excessively large file" do
    publisher = publishers(:completed)
    sign_in publisher

    get home_publishers_path
    assert_response :success

    site_banner = site_banners(:completed)

    fake_data = "A" * Publishers::SiteBannersController::MAX_IMAGE_SIZE
    post(update_logo_publisher_site_banners_path(publisher.id), params: {image: "data:image/jpeg;base64," + fake_data})

    publisher.reload
    assert_nil publisher.site_banners.last.logo.attachment
  end

  test "publisher can upload a normally sized file" do
    publisher = publishers(:completed)
    sign_in publisher

    get home_publishers_path
    assert_response :success

    site_banner = site_banners(:completed)

    source_image_path = "./app/assets/images/brave-lion@3x.jpg"
    fake_data = Base64.encode64(open(source_image_path) { |io| io.read })
    post(update_logo_publisher_site_banners_path(publisher.id), params: {image: "data:image/jpeg;base64," + fake_data})

    publisher.reload
    assert_not_nil publisher.site_banners.last.logo.attachment
  end
end

require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PublishersHelper

  test "Show method retrieves a site_banner by uuid" do
      publisher = publishers(:default)
      sign_in publisher
      get '/publishers/' + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      site_banner = JSON.parse(response.body)
      assert_equal("Hello World", site_banner["title"])
      assert_equal("Lorem Ipsum", site_banner["description"])
  end

  test "Show method returns nil if site_banner not found" do
      publisher = publishers(:default)
      sign_in publisher
      get '/publishers/' + publisher.id + "/site_banners/wrong-id", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      site_banner = JSON.parse(response.body)
      assert_nil(site_banner)
  end

  test "Updating a banner with valid data will return 200" do
      publisher = publishers(:default)
      sign_in publisher

      put '/publishers/' + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000",
      headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" },
      params: {title: "Hello Update", description: "Updated Desc", donation_amounts: [5, 10, 15].to_json}

      assert_response :success
  end

  test "publisher cannot upload an excessively large file" do
    publisher = publishers(:default)
    site_banner = site_banners(:default)
    sign_in publisher

    fake_data = "A" * Publishers::SiteBannersController::MAX_IMAGE_SIZE
    put '/publishers/' + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000",
    headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" },
    params: {logo: "data:image/jpeg;base64," + fake_data, title: "Hello Update", description: "Updated Desc", donation_amounts: [5, 10, 15].to_json}

    publisher.reload
    assert_nil site_banner.logo.attachment
  end

  test "publisher cannot upload a normally sized file" do
    publisher = publishers(:default)
    site_banner = site_banners(:default)
    sign_in publisher

    source_image_path = "./app/assets/images/brave-lion@3x.jpg"
    fake_data = Base64.encode64(open(source_image_path) { |io| io.read })
    put '/publishers/' + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000",
    headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" },
    params: {logo: "data:image/jpeg;base64," + fake_data, title: "Hello Update", description: "Updated Desc", donation_amounts: [5, 10, 15].to_json}

    publisher.reload
    assert_not_nil site_banner.logo.attachment
  end
end

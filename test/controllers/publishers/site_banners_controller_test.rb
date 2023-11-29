# typed: false

require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PublishersHelper

  test "Show method retrieves a site_banner by uuid" do
    publisher = publishers(:default)
    new_site_banner = publisher.channels.verified.last.site_banner
    new_site_banner.logo.attach(
      {
        io: File.open("#{Rails.root}/test/fixtures/1x1.png"),
        filename: "test.jpg",
        content_type: "image/jpg"
      }
    )
    new_site_banner.save!
    sign_in publisher.reload
    get "/publishers/" + publisher.id + "/site_banners/#{new_site_banner.id}", headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"}
    site_banner = JSON.parse(response.body)
    assert_equal("Ann Bothman", site_banner["title"])
    assert_equal("https://TESTDOMAIN.com/#{new_site_banner.logo.blob.key}", site_banner["logoUrl"])
    assert_equal("Hi there! My name is Ann and I am a travel blogger and photographer. I have always had a passion for exploring new places and immersing myself in different cultures.", site_banner["description"])
  end

  test "Show method returns nil if site_banner not found" do
    publisher = publishers(:default)
    sign_in publisher
    get "/publishers/" + publisher.id + "/site_banners/wrong-id", headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"}
    site_banner = JSON.parse(response.body)
    assert_nil(site_banner)
  end

  test "Updating a banner with valid data will return 200" do
    publisher = publishers(:default)
    sign_in publisher

    put "/publishers/" + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000",
      headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"},
      params: {title: "Hello Update", description: "Updated Desc"}

    assert_response(200)
    publisher.reload
  end

  test "publisher cannot upload an excessively large file" do
    publisher = publishers(:default)
    site_banner = site_banners(:default)
    sign_in publisher

    fake_data = "A" * Publishers::SiteBannersController::MAX_IMAGE_SIZE
    put "/publishers/" + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000",
      headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"},
      params: {logo: "data:image/jpeg;base64," + fake_data, title: "Hello Update", description: "Updated Desc"}

    assert_equal JSON.parse(@response.body)["message"], I18n.t("banner.upload_too_big")

    publisher.reload
    assert_nil site_banner.logo.attachment
  end

  test "publisher can upload a normally sized file" do
    publisher = publishers(:default)
    site_banner = site_banners(:default)
    refute site_banner.logo.attachment

    sign_in publisher

    source_image_path = "./app/assets/images/brave-lion@3x.jpg"
    fake_data = Base64.encode64(open(source_image_path) { |io| io.read }) # standard:disable Security/Open
    put "/publishers/" + publisher.id + "/site_banners/00000000-0000-0000-0000-000000000000",
      headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"},
      params: {logo: "data:image/jpeg;base64," + fake_data, title: "Hello Update", description: "Updated Desc"}

    publisher.reload
    assert site_banner.reload.logo.attachment
  end
end

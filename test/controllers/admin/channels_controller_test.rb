# typed: false

require "test_helper"
require "webmock/minitest"

class Admin::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    get admin_publishers_path
    assert_select "title", "Not authorized"
  end

  test "filters correctly" do
    admin = publishers(:admin)
    channel = channels(:completed)
    sign_in admin

    get admin_channels_path
    assert_response :success
    assert_select "tbody" do
      assert_select "tr" do
        assert_select "td", channel.id
      end
    end
  end

  test "filters correctly 2" do
    admin = publishers(:admin)
    channel = channels(:completed)
    sign_in admin

    query = SiteChannelDetails.find(channel.details_id).brave_publisher_id

    get admin_channels_path, params: {q: query}
    assert_response :success
    # For some reason the old assert_select still picks up the previous page, even though the response.body shows empty results
    # So use nokogiri
    doc = Nokogiri::HTML(response.body)
    assert doc.search("tbody > tr").size == 6

    assert_select "tbody" do
      assert_select "td", channel.id
    end
  end

  test "filters correctly 3" do
    admin = publishers(:admin)
    channel = channels(:completed)
    sign_in admin

    SiteChannelDetails.find(channel.details_id).brave_publisher_id

    get admin_channels_path, params: {q: "failure"}
    assert_response :success

    # For some reason the old assert_select still picks up the previous page, even though the response.body shows empty results
    # So use nokogiri
    doc = Nokogiri::HTML(response.body)
    assert doc.search("tbody > tr").blank?
  end
end

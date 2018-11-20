require "test_helper"
require "webmock/minitest"

class Admin::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) do
      get admin_publishers_path
    end
  end

  test "filters correctly" do
    admin = publishers(:admin)
    channel = channels(:completed)
    sign_in admin

    query = SiteChannelDetails.find(channel.details_id).brave_publisher_id

    get admin_channels_path
    assert_response :success
    assert_select "tbody" do
      assert_select "tr" do
        assert_select "td", channel.id
      end
    end

    get admin_channels_path, params: { q: query }
    assert_response :success
    assert_select "tbody" do
      assert_select "tr", 1
      assert_select "td", channel.id
    end

    get admin_channels_path, params: { q: "failure" }
    assert_response :success
    assert_select "tbody" do
      assert_select "tr", false
    end
  end
end

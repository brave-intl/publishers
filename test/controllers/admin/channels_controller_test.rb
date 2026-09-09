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

  test "index reports when the OFAC services have never run" do
    sign_in publishers(:admin)

    get admin_channels_path

    assert_response :success
    assert_select "time.job-time", count: 0
    assert_match "no successful run recorded", response.body
  end

  test "index shows the last successful run of each OFAC service" do
    sign_in publishers(:admin)

    ofac_list_run = ServiceRun.record_success!(ParseOfacListService)
    disconnect_run = ServiceRun.record_success!(Wallet::DisconnectInvalidP2pAddressService)

    get admin_channels_path

    assert_response :success
    assert_select "time.job-time", count: 2
    assert_select "time.job-time[datetime=?]", ofac_list_run.created_at.iso8601
    assert_select "time.job-time[datetime=?]", disconnect_run.created_at.iso8601
    assert_no_match "no successful run recorded", response.body
  end

  test "index shows the most recent run when a service has run more than once" do
    sign_in publishers(:admin)

    travel_to 2.days.ago do
      ServiceRun.record_success!(ParseOfacListService)
    end
    latest = ServiceRun.record_success!(ParseOfacListService)

    get admin_channels_path

    assert_response :success
    assert_select "time.job-time", count: 1
    assert_select "time.job-time[datetime=?]", latest.created_at.iso8601
  end
end

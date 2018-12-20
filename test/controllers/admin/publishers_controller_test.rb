require 'test_helper'
require "webmock/minitest"

class Admin::PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  def stub_verification_public_file(channel, body: nil, status: 200)
    url = "https://#{channel.details.brave_publisher_id}/.well-known/brave-payments-verification.txt"
    headers = {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby'
    }
    body ||= SiteChannelVerificationFileGenerator.new(site_channel: channel).generate_file_content
    stub_request(:get, url).
      with(headers: headers).
      to_return(status: status, body: body, headers: {})
  end

  before do
    @prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
  end

  after do
    Rails.application.secrets[:host_inspector_offline] = @prev_host_inspector_offline
  end

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      get admin_publishers_path
    }
  end

  test "admin can access" do
    admin = publishers(:admin)
    sign_in admin

    get admin_publishers_path
    assert_response :success
  end

  test "admin filters appropriately on name & email" do
    admin = publishers(:admin)
    publisher = Publisher.order(created_at: :asc).first
    sign_in admin

    get admin_publishers_path
    assert_response :success
    assert_select 'tbody' do
      assert_select 'tr' do
        assert_select 'td', publisher.id
      end
    end

    get admin_publishers_path, params: {q: "#{publisher.name}"}
    assert_response :success
    assert_select 'tbody' do
      assert_select 'tr', true
    end

    get admin_publishers_path, params: {q: "#{publisher.name}failure"}
    assert_response :success
    assert_select 'tbody' do
      assert_select 'tr', false
    end
  end

  describe 'search' do
    before do
      admin = publishers(:admin)
      publisher = publishers(:completed)
      sign_in admin
    end

    it 'searches referral codes' do
      get admin_publishers_path, params: { q: "PRO123" }

      publishers = controller.instance_variable_get("@publishers")
      assert_equal publishers.length, 1
      assert_equal publishers.first, publishers(:promo_enabled)
    end

    it 'only shows suspended when suspended filter is on' do
      get admin_publishers_path, params: { suspended: "1" }

      publishers = controller.instance_variable_get("@publishers")

      publishers.each do |p|
        assert_equal p.last_status_update.status, "suspended"
      end
    end

    it 'filters correctly on name' do
      get admin_publishers_path, params: { q: "#{publishers(:completed).name}" }

      publishers = controller.instance_variable_get("@publishers")
      assert_equal publishers.length, 1
      assert_equal publishers.first, publishers(:completed)
    end

    it 'returns no results when not found' do
      get admin_publishers_path, params: { q: "404 not found" }

      publishers = controller.instance_variable_get("@publishers")
      assert_equal publishers.length, 0
    end
  end

  test "raises error unless admin has u2f enabled" do
    admin = publishers(:admin)
    admin.u2f_registrations.each { |r| r.destroy } # remove all u2f registrations
    admin.reload
    sign_in admin

    assert_raises(Ability::U2fDisabledError) do
      get admin_publishers_path
    end
  end

  test "raises error unless admin is on admin whitelist" do
    admin = publishers(:admin)
    sign_in admin

    assert_raises(Ability::AdminNotOnIPWhitelistError) do
      get admin_publishers_path, headers: { 'REMOTE_ADDR' => '1.2.3.4' } # not on whitelist
    end
  end

  test "admins can approve channels waiting for admin approval" do
    Rails.application.secrets[:host_inspector_offline] = false
    admin = publishers(:admin)
    c = channels(:to_verify_restricted)
    stub_verification_public_file(c)

    # simulate verification attempt that will be blocked
    verifier = SiteChannelVerifier.new(channel: c)
    verifier.perform
    c.reload
    assert c.verification_awaiting_admin_approval?

    # simulate admin approving channel
    sign_in admin
    patch approve_channel_admin_publishers_path(channel_id: c.id)
    c.reload
    assert c.verified?
    assert c.verification_approved_by_admin?
  end
end

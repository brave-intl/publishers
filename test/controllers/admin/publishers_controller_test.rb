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

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      get admin_publishers_path
    }
  end

  test "regular users cannot make partner" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      post admin_publisher_make_partner_path(publisher.id)
    }
  end

  test "admin can make publisher a parnter" do
    admin = publishers(:admin)
    sign_in admin

    publisher = Publisher.where(role: Publisher::PUBLISHER).first

    # Make request
    assert_enqueued_emails(1) do
      post admin_publisher_make_partner_path(publisher.id)
    end

    publisher.reload

    assert publisher.partner?
  end

  test "admin can access" do
    admin = publishers(:admin)
    sign_in admin

    get admin_publishers_path
    assert_response :success
  end

  test "admin filters appropriately on name & email" do
    admin = publishers(:admin)
    publisher = publishers(:completed)
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

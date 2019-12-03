require 'test_helper'
require "webmock/minitest"


class Admin::UnattachedPromoRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include PromosHelper
  include Devise::Test::IntegrationHelpers

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_promo_base_uri] # Presence of this envar means we use external requiests
  end

  after(:example) do
    Rails.application.secrets[:api_promo_base_uri] = @prev_offline
  end

  test "#create creates codes" do
    Rails.application.secrets[:api_promo_base_uri] = "http://127.0.0.1:8194" # Turn on external requests
    admin = publishers(:admin)
    sign_in admin

    stub_request(:put, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/referral_code/unattached?number=1")
      .to_return(status: 200, body: [{"referral_code":"NDF915","ts":"2018-10-12T20:06:50.125Z","type":"unattached","owner_id":"","channel_id":"","status":"active"}].to_json)

    assert_difference -> { PromoRegistration.count }, 1 do
      post(admin_unattached_promo_registrations_path, params: {number_of_codes_to_create: "1"})
    end

    assert_equal PromoRegistration.order("created_at").last.kind, "unattached"
  end

  test "#update_statuses updates the status of codes" do
    Rails.application.secrets[:api_promo_base_uri] = "http://127.0.0.1:8194"
    admin = publishers(:admin)
    sign_in admin

    promo_registration = PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", active: true, promo_id: active_promo_id)

    stub_request(:patch, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/referral?referral_code=ABC123").
      with(body: {status: "paused"}.to_json).
      to_return(status: 200)

    patch(update_statuses_admin_unattached_promo_registrations_path, params: {referral_codes: ["ABC123"], referral_code_status: "paused"})

    refute promo_registration.reload.active
  end

  test "#assign_campaign assigns codes to a campaign" do
    admin = publishers(:admin)
    sign_in admin

    promo_registration_1 = PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: active_promo_id)
    promo_registration_2 = PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: active_promo_id)
    PromoCampaign.create!(name: "October 2018")

    patch(assign_campaign_admin_unattached_promo_registrations_path, params: {referral_codes: ["ABC123", "DEF456"], promo_campaign_target: "October 2018"})

    campaign = PromoCampaign.where(name: "October 2018").first

    assert_equal campaign.promo_registrations.count, 2
    assert campaign.promo_registrations.include?(promo_registration_1)
    assert campaign.promo_registrations.include?(promo_registration_2)
  end

  test "#assign_installer_type assigns installer type to codes" do
    Rails.application.secrets[:api_promo_base_uri] = "http://127.0.0.1:8194" # Turn on external requests
    admin = publishers(:admin)
    sign_in admin

    promo_registration_1 = PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: active_promo_id)
    promo_registration_2 = PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: active_promo_id)

    stub_request(:put, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/referral/installerType").
      to_return(status: 200)

    put(assign_installer_type_admin_unattached_promo_registrations_path, params: {referral_codes: ["ABC123", "DEF456"], installer_type: PromoRegistration::MOBILE})

    assert_equal promo_registration_1.reload.installer_type, PromoRegistration::MOBILE
    assert_equal promo_registration_2.reload.installer_type, PromoRegistration::MOBILE
  end

  test "cannot #create more than 50 codes at a time" do
    admin = publishers(:admin)
    sign_in admin

    assert_difference -> { PromoRegistration.count }, 0 do
      post(admin_unattached_promo_registrations_path, params: {number_of_codes_to_create: "51"})
    end

    assert_equal flash[:alert], "Can't create more than 50 codes at a time."
  end
end

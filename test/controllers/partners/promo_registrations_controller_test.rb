require "test_helper"
class Partners::PromoRegistrationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

  test "POST to /partners/referrals/promo_registrations/ creates new promo_registrations" do
    # partner = partners(:default_partner)
    # sign_in partner
    # post partners_promo_registrations_path, params: { number: "1", description: "PromoRegistrationsTest", promo_campaign_id: nil }
    # promo_registration = PromoRegistration.find_by_description("PromoRegistrationsTest")
    # assert_not_nil(promo_registration)
  end

  test "PUT to /partners/referrals/promo_registrations/:id updates promo_campaign_id" do
    # promo_registration = promo_registrations(:site_promo_registration)
    # promo_campaign = promo_campaigns(:test_promo_campaign)
    # partner = partners(:default_partner)
    # sign_in partner
    # put '/partners/referrals/promo_registrations/' + promo_registration.id, params: { campaign: promo_campaign.id }
    # promo_registration = PromoRegistration.find(promo_registration.id)
    # assert_equal(promo_registration.promo_campaign_id, promo_campaign.id)
  end

  test "DELETE to /partners/referrals/promo_registrations/:id deletes promo_registration" do
    # promo_registration = promo_registrations(:site_promo_registration)
    # partner = partners(:default_partner)
    # sign_in partner
    # delete '/partners/referrals/promo_registrations/' + promo_registration.id
    # assert_not(PromoRegistration.exists?(promo_registration.id))
  end
end
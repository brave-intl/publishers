require "test_helper"
class Partners::PromoCampaignsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

  test "POST to /partners/referrals/promo_campaigns/ creates new promo_registrations" do
    partner = partners(:default_partner)
    sign_in partner
    post partners_promo_campaigns_path, params: { name: "PromoCampaignsTest" }
    promo_campaign = PromoCampaign.find_by_name("PromoCampaignsTest")
    assert_not_nil(promo_campaign)
  end

  test "PUT to /partners/referrals/promo_campaigns/:id updates promo_campaign name" do
    promo_campaign = promo_campaigns(:test_promo_campaign)
    partner = partners(:default_partner)
    sign_in partner
    put '/partners/referrals/promo_campaigns/' + promo_campaign.id, params: { name: "PromoCampaignsUpdate" }
    promo_campaign = PromoCampaign.find_by_name("PromoCampaignsUpdate")
    assert_not_nil(promo_campaign)
  end

  test "DELETE to /partners/referrals/promo_campaigns/:id deletes promo_campaign" do
    promo_campaign = promo_campaigns(:test_promo_campaign)
    partner = partners(:default_partner)
    sign_in partner
    delete '/partners/referrals/promo_campaigns/' + promo_campaign.id
    assert_not(PromoCampaign.exists?(promo_campaign.id))
  end
end
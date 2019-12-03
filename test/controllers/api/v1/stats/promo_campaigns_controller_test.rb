require "test_helper"

class Api::V1::Stats::PromoCampaignsControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/stats/promo_campaigns/ returns json representation of all campaigns" do
    promo_campaign = promo_campaigns(:test_promo_campaign)
    promo_campaign2 = promo_campaigns(:test_promo_campaign2)
    promo_registration = promo_registrations(:owner_promo_registration)
    promo_registration2 = promo_registrations(:unattached_promo_registration)
    get "/api/v1/stats/promo_campaigns/", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      assert_equal(
        [{
          promo_campaign_id: promo_campaign.id,
          name: "test campaign",
          promo_registrations: [
            { promo_registration_id: promo_registration.id, referral_code: "PRO789" }
          ]
        },
        {
          promo_campaign_id: promo_campaign2.id,
          name: "test campaign2",
          promo_registrations: [
            { promo_registration_id: promo_registration2.id, referral_code: "PRO012" }
          ]
        }],
        JSON.parse(response.body, symbolize_names: true)
      )
  end

  test "/api/v1/stats/promo_campaigns/:id returns json representation of a campaign" do
    promo_campaign = promo_campaigns(:test_promo_campaign)
    promo_registration = promo_registrations(:owner_promo_registration)
    get "/api/v1/stats/promo_campaigns/" + promo_campaign.id, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      assert_equal(
        {
          promo_campaign_id: promo_campaign.id,
          name: "test campaign",
          promo_registrations: [
            { promo_registration_id: promo_registration.id, referral_code: "PRO789" }
          ]
        },
        JSON.parse(response.body, symbolize_names: true)
      )
  end
end

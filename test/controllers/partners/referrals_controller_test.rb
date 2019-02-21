require "test_helper"
class Partners::ReferralsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

  test "/partners/referrals/ returns organization's campaigns" do
    partner = partners(:default_partner)
    campaign = promo_campaigns(:test_promo_campaign)
    sign_in partner
    get partners_referrals_path, headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' }
    data = JSON.parse(response.body, symbolize_names: true)
    assert_equal(data[:campaigns][0][:name], campaign.name)
  end
end
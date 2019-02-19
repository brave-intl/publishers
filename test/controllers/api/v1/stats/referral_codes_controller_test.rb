require "test_helper"
class Api::V1::Stats::ReferralCodesControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/stats/referral_codes/ returns all referral codes" do
    get "/api/v1/stats/referral_codes/", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    data = JSON.parse(response.body, symbolize_names: true)
    assert_equal(data, ["PRO123", "PRO456", "PRO789", "PRO012"])
  end

  test "/api/v1/stats/referral_codes/:id returns channel data of a referral code" do
    promo_registration = promo_registrations(:site_promo_registration)
    channel = Channel.find(promo_registration.channel.id)
    get "/api/v1/stats/referral_codes/" + promo_registration.referral_code, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    data = JSON.parse(response.body, symbolize_names: true)
    assert_equal(data[:channel][:channel_name], "promotion.org")
    assert_equal(data[:channel][:channel_type], "Site")
    assert_equal(data[:channel][:verified], true)
  end
end
require "test_helper"

class Api::V1::PromoRegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/promo_registrations/:referral_code/publisher_status_updates updates a publisher status via referral code" do
    promo_registration = promo_registrations(:site_promo_registration)
    post "/api/v1/promo_registrations/" + promo_registration.referral_code + "/publisher_status_updates",
      headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" },
      params: { status: "suspended", note: "yolo", admin: "hello@brave.com"}
    status = promo_registration.publisher.last_status_update.status
    assert_equal("suspended", status)
  end
end

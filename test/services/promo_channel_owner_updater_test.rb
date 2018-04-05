require "test_helper"
require "webmock/minitest"

class PromoChannelOwnerUpdaterTest < ActiveJob::TestCase
  test "request has the correct format" do
    # Presence of api_promo_base_uri determines whether to perform offline
    prev_api_promo_base_uri = Rails.application.secrets[:api_promo_base_uri]
    begin
      Rails.application.secrets[:api_promo_base_uri] = "https://127.0.0.1:8194"
      
      publisher = publishers(:bart_the_promo_enabled)
      referral_code = publisher.channels.first.promo_registration.referral_code

      stub_request(:put, /api\/1\/promo\/publishers\/#{referral_code}/)
          .with(body: "{\"owner_id\":\"#{publisher.owner_identifier}\"}")
          .to_return(status: 200, body: nil, headers: {})

      result = PromoChannelOwnerUpdater.new(publisher: publisher, referral_code: referral_code).perform
      assert 200, result.status      
    ensure
      Rails.application.secrets[:api_promo_base_uri] = prev_api_promo_base_uri
    end
  end
end
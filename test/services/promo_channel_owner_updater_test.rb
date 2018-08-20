require "test_helper"
require "webmock/minitest"
 class PromoChannelOwnerUpdaterTest < ActiveJob::TestCase

  before do
    @prev_offline = Rails.application.secrets[:api_promo_base_uri]
  end

  after do
    Rails.application.secrets[:api_promo_base_uri] = @prev_offline
  end

  test "request has the correct format" do
    Rails.application.secrets[:api_promo_base_uri] = "https://127.0.0.1:8194"
    
    publisher = publishers(:bart_the_promo_enabled)
    referral_code = publisher.channels.first.promo_registration.referral_code
     stub_request(:put, /api\/1\/promo\/publishers\/#{referral_code}/)
        .with(body: "{\"owner_id\":\"#{publisher.id}\"}")
        .to_return(status: 200, body: nil, headers: {})
     result = PromoChannelOwnerUpdater.new(publisher: publisher, referral_code: referral_code).perform
    assert 200, result.status      
  end
end 
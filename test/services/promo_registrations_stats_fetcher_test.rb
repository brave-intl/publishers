require "test_helper"
require "webmock/minitest"

class PromoRegistrationsStatsFetcherTest < ActiveJob::TestCase
  include PromosHelper

  before(:example) do
    @prev_promo_api_uri = Rails.application.secrets[:api_promo_base_uri]
  end

  after(:example) do
    Rails.application.secrets[:api_promo_base_uri] = @prev_promo_api_uri
  end

  test "saves the stats" do
    # ensure an external request is attempted to be stubbed by turning on promo
    Rails.application.secrets[:api_promo_base_uri] = "http://127.0.0.1:8194"

    # create two registrations
    PromoRegistration.create(promo_id: active_promo_id, referral_code: "ABC123", kind: PromoRegistration::UNATTACHED)
    PromoRegistration.create(promo_id: active_promo_id, referral_code: "DEF456", kind: PromoRegistration::UNATTACHED)

    # stub the response body
    stubbed_response_body = [{
      "referral_code"=>"ABC123",
      "ymd"=>"2018-04-29",
      "retrievals"=>0,
      "first_runs"=>1,
      "finalized"=>1},
     {"referral_code"=>"ABC123",
      "ymd"=>"2018-05-12",
      "retrievals"=>0,
      "first_runs"=>1,
      "finalized"=>0},
     {"referral_code"=>"DEF456",
      "ymd"=>"2018-06-17",
      "retrievals"=>0,
      "first_runs"=>1,
      "finalized"=>0}].to_json

    request_url = "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/statsByReferralCode?referral_code=ABC123&referral_code=DEF456"
    stub_request(:get, request_url)
      .to_return(status: 200, body: stubbed_response_body)

    promo_registrations = PromoRegistration.where(referral_code: ["ABC123", "DEF456"])
    PromoRegistrationsStatsFetcher.new(promo_registrations: promo_registrations).perform

    assert_equal 2, PromoRegistration.find_by_referral_code("ABC123").aggregate_stats[PromoRegistration::FIRST_RUNS]
    assert_equal 1, PromoRegistration.find_by_referral_code("DEF456").aggregate_stats[PromoRegistration::FIRST_RUNS]
  end
end
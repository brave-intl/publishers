# Fetches and updates the stats for all types of referral codes
class Promo::RegistrationsStatsFetcher < BaseApiClient
  include PromosHelper
  BATCH_SIZE = 100

  def initialize(promo_registrations:)
    @referral_codes = promo_registrations.map { |promo_registration| promo_registration.referral_code }
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_promo_base_uri].blank?
    @referral_codes.each_slice(BATCH_SIZE).to_a.each do |referral_code_batch|
      query_string = query_string(referral_code_batch)
      response = connection.get do |request|
        request.options.params_encoder = Faraday::FlatParamsEncoder
        request.headers["Authorization"] = api_authorization_header
        request.headers["Content-Type"] = "application/json"
        request.url("/api/2/promo/statsByReferralCode#{query_string}")
      end

      referral_code_events_by_date = JSON.parse(response.body)

      referral_code_batch.each do |referral_code|
        promo_registration = PromoRegistration.find_by_referral_code(referral_code)
        promo_registration.stats = referral_code_events_by_date.select {|referral_code_event_date|
          referral_code_event_date["referral_code"] == referral_code
        }.to_json
        promo_registration.save!
      end
    end
  end

  def perform_offline
    true
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end

  def query_string(referral_codes)
    query_string = "?"
    referral_codes.each do |referral_code|
      query_string = "#{query_string}referral_code=#{referral_code}&"
    end
    query_string.chomp("&") # Remove the final ampersand
  end
end
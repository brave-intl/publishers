# Fetches and does not save geo stats for a list of referral_codes
class Promo::RegistrationsGeoStatsFetcher < BaseApiClient
  include PromosHelper
  BATCH_SIZE = 10
  MAX_RETRY = 3

  def initialize(referral_codes:, start_date: nil, end_date: nil, interval: nil)
    @referral_codes = referral_codes
    @start_date = start_date
    @end_date = end_date
    @interval =
      case interval
      when PromoRegistration::DAILY
        'day'
      when PromoRegistration::WEEKLY
        'week'
      when PromoRegistration::MONTHLY
        'month'
      end
  end

  def perform
    params = {
      start_date: @start_date,
      end_date: @end_date,
      interval: @interval,
    }

    return perform_offline if Rails.application.secrets[:api_promo_base_uri].blank?

    geo_stats = []
    @referral_codes.each_slice(BATCH_SIZE).to_a.each do |batch|
      response = retry_request(MAX_RETRY) do
        request({ referral_code: batch }.merge(params))
      end

      raise StandardError.new(message: 'Could not fetch geo stats due to an error from Promo Server') if response.blank?

      geo_stats += JSON.parse(response.body)
    end

    geo_stats
  end

  def request(params)
    connection.get do |request|
      request.options.params_encoder = Faraday::FlatParamsEncoder
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.params = params.compact
      request.url("/api/2/promo/geoStatsByReferralCode")
    end
  rescue Faraday::ClientError => e
    Rails.logger.info("Error receiving referral stats #{e.message}")
    nil
  end

  def retry_request(allowed_retries)
    result = nil
    retry_count = 0
    loop do
      result = yield
      break if result || retry_count > allowed_retries

      retry_count += 1
    end

    result
  end

  def perform_offline
    geo_stats = []
    @referral_codes.each do |referral_code|
      ((1.month.ago.utc.to_date)..(Time.now.utc.to_date)).each do |day|
        usa_event = {
          "referral_code" => "#{referral_code}",
          PromoRegistration::COUNTRY => "United States",
          PromoRegistration::RETRIEVALS => 1,
          PromoRegistration::FIRST_RUNS => 1,
          PromoRegistration::FINALIZED => 1,
          "ymd" => "#{day}",
        }

        mexico_event = usa_event.dup
        mexico_event[PromoRegistration::COUNTRY] = "Mexico"
        geo_stats.push(usa_event)
        geo_stats.push(mexico_event)
      end
    end

    geo_stats
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

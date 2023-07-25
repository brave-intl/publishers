# typed: false

# Fetches and updates the stats for all types of referral codes
class Promo::RegistrationsStatsFetcher < BaseApiClient
  include PromosHelper
  BATCH_SIZE = 50

  def initialize(promo_registrations:, update_only: false)
    @promo_registrations = promo_registrations
    @update_only = update_only
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_promo_base_uri].blank?
    stats = []
    @promo_registrations.in_batches(of: BATCH_SIZE) do |promo_registrations_batch|
      query_string = query_string(promo_registrations_batch)
      response = connection.get do |request|
        request.options.params_encoder = Faraday::FlatParamsEncoder
        request.headers["Authorization"] = api_authorization_header
        request.headers["Content-Type"] = "application/json"
        request.url("/api/2/promo/statsByReferralCode#{query_string}")
      end
      referral_code_events_by_date = JSON.parse(response.body)
      values = []
      promo_registrations_batch.each do |promo_registration|
        promo_registration.stats = referral_code_events_by_date.select { |referral_code_event_date|
          referral_code_event_date["referral_code"] == promo_registration.referral_code
        }.to_json
        promo_registration.aggregate_downloads = promo_registration.aggregate_stats[PromoRegistration::RETRIEVALS]
        promo_registration.aggregate_installs = promo_registration.aggregate_stats[PromoRegistration::FIRST_RUNS]
        promo_registration.aggregate_confirmations = promo_registration.aggregate_stats[PromoRegistration::FINALIZED]
        values.append("(
          #{ActiveRecord::Base.connection.quote(promo_registration.id)},
          #{to_postgres_array(promo_registration.stats)}::json,
          #{promo_registration.aggregate_downloads},
          #{promo_registration.aggregate_installs},
          #{promo_registration.aggregate_confirmations})")
      end
      query = "
          UPDATE promo_registrations
          SET stats = uv.stats,
              aggregate_downloads = uv.aggregate_downloads,
              aggregate_installs = uv.aggregate_installs,
              aggregate_confirmations = uv.aggregate_confirmations
          FROM (VALUES #{values.join(", ")}) AS uv (id, stats, aggregate_downloads, aggregate_installs, aggregate_confirmations)
          WHERE promo_registrations.id = uv.id::uuid"

      ActiveRecord::Base.connection.execute(query)
      # Manually update updated_at
      promo_registrations_batch.update_all(updated_at: Time.now)
      stats += referral_code_events_by_date unless @update_only
    end

    stats
  end

  def to_postgres_array(result)
    result = result.to_s
    result[0] = "'["
    result[-1] = "]'"
    result
  end

  def perform_offline
    stats = []
    @promo_registrations.pluck(:referral_code).each do |referral_code|
      events = []
      (1..6).reverse_each do |i|
        (1..3).each do |j|
          event = {
            "referral_code" => referral_code.to_s,
            PromoRegistration::RETRIEVALS => rand(50..75),
            PromoRegistration::FIRST_RUNS => rand(30..50),
            PromoRegistration::FINALIZED => rand(1..30),
            "ymd" => i.month.ago.utc.to_date.to_s
          }
          events.push(event)
          stats.push(event)
        end
      end
      PromoRegistration.find_by_referral_code(referral_code).update(stats: events.to_json)
    end

    stats
  end

  private

  # This should override the method in the base and fix this only for promos
  def proxy_url
    nil
  end

  def retry_count
    0
  end

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end

  def query_string(promo_registrations)
    referral_codes = promo_registrations.pluck(:referral_code)
    "?" + referral_codes.map { |referral_code| "referral_code=#{referral_code}" }.join("&")
  end
end

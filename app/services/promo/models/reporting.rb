require 'addressable/template'
require 'json'

module Promo
  module Models
    class Reporting < Client
      BATCH_SIZE = 10

      def geo_stats_by_referral_code(referral_codes:, start_date:, end_date:, interval: nil)
        return perform_offline(referral_codes, start_date, end_date) if Rails.application.secrets[:api_promo_base_uri].blank?

        path = "api/2/promo/geoStatsByReferralCode"

        params = {
          start_date: start_date,
          end_date: end_date,
          interval: interval,
        }

        geo_stats = []
        referral_codes.each_slice(BATCH_SIZE).to_a.each do |batch|
          response = get(path, { referral_code: batch }.merge(params))

          geo_stats += JSON.parse(response.body)
        end

        geo_stats
      end

      def perform_offline(referral_codes, start_time, end_time)
        geo_stats = []
        referral_codes.each do |referral_code|
          (start_time..end_time).each do |day|
            usa_event = {
              "referral_code" => referral_code,
              PromoRegistration::COUNTRY => "United States",
              PromoRegistration::RETRIEVALS => 1,
              PromoRegistration::FIRST_RUNS => 1,
              PromoRegistration::FINALIZED => 1,
              "ymd" => day.to_s,
            }

            mexico_event = usa_event.dup
            mexico_event[PromoRegistration::COUNTRY] = "Mexico"
            geo_stats.push(usa_event)
            geo_stats.push(mexico_event)
          end
        end

        geo_stats
      end

      # Increases the amount of retries for this request from the default to 5.
      def retry_count
        5
      end
    end
  end
end

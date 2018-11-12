# Fetches and saves the referral stats for unattached codes
class SyncUnattachedPromoRegistrationsStatsJob < ApplicationJob
  include PromosHelper
  queue_as :low

  def perform(promo_id: active_promo_id)
    promo_registrations = PromoRegistration.unattached_only
    success = PromoRegistrationsStatsFetcher.new(promo_registrations: promo_registrations).perform

    if success
      Rails.cache.write("unattached_promo_registration_stats_last_synced_at", Time.now)
    end
  end
end
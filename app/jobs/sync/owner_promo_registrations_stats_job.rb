# Fetches and saves the referral stats for unattached codes
class Sync::OwnerPromoRegistrationsStatsJob < ApplicationJob
    include PromosHelper
    queue_as :low
  
    def perform
      promo_registrations = PromoRegistration.owner_only
      success = Promo::RegistrationsStatsFetcher.new(promo_registrations: promo_registrations).perform
  
      if success
        Rails.cache.write("owner_promo_registration_stats_last_synced_at", Time.now)
      end
    end
  end
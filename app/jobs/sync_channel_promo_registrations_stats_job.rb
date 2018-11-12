# Fetches and saves the referral stats for channel owned codes
class SyncChannelPromoRegistrationsStatsJob < ApplicationJob
  include PromosHelper
  queue_as :scheduler

  def perform(promo_id: active_promo_id)
    promo_registrations = PromoRegistration.channel
    success = PromoRegistrationsStatsFetcher.new(promo_registrations: promo_registrations).perform
  end
end
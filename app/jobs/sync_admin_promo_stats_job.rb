# Fetches and saves the referral stats for admins
class SyncAdminPromoStatsJob < ApplicationJob
  include PromosHelper
  queue_as :low

  def perform(promo_id: active_promo_id)
    promo_registrations = PromoRegistration.where(kind: "unattached")
    AdminPromoStatsFetcher.new(promo_registrations: promo_registrations).perform
  end
end
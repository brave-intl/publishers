# typed: ignore

# Fetches and saves the referral stats for channel owned codes
class Sync::ChannelPromoRegistrationsStatsJob < ApplicationJob
  include PromosHelper

  def perform
    active_publisher_ids = Publisher.not_suspended
    promo_registration_ids = PromoRegistration.channels_only.where(publisher_id: active_publisher_ids).pluck(:id)
    ids = []
    promo_registration_ids.each do |promo_registration_id|
      ids << promo_registration_id
      if ids.count >= 50
        Sync::PromoRegistrationStatsJob.perform_async(ids)
        ids = []
      end
    end
    Sync::PromoRegistrationStatsJob.perform_async(ids) if ids.count > 0
  end
end

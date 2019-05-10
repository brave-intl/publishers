# Fetches and saves the referral stats for channel owned codes
class Sync::ChannelPromoRegistrationsStatsJob < ApplicationJob
  include PromosHelper

  def perform
    active_publisher_ids = Publisher.not_suspended
    promo_registrations = PromoRegistration.channels_only.where(publisher_id: active_publisher_ids)
    Promo::RegistrationsStatsFetcher.new(promo_registrations: promo_registrations, update_only: true).perform
  end
end

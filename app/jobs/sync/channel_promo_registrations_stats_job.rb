# Fetches and saves the referral stats for channel owned codes
class Sync::ChannelPromoRegistrationsStatsJob < ApplicationJob
  include PromosHelper
  queue_as :scheduler

  def perform
    promo_registrations = PromoRegistration.channels_only
    Promo::RegistrationsStatsFetcher.new(promo_registrations: promo_registrations).perform
  end
end
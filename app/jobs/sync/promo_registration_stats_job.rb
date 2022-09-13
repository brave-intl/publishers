# typed: true

class Sync::PromoRegistrationStatsJob
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(promo_registration_ids)
    Promo::RegistrationsStatsFetcher.new(promo_registrations: PromoRegistration.where(id: promo_registration_ids), update_only: true).perform
  end
end

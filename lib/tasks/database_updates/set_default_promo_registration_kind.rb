namespace :database_updates do
  task :set_default_promo_registration_kind => [:environment] do
    registrations = PromoRegistration.where.not(channel_id: nil).where(kind: nil)
    registrations.update_all!(kind: "channel")
  end
end
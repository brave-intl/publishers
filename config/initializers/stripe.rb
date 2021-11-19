# typed: strict
if Rails.application.config.services.stripe[:client_secret].present?
  Rails.configuration.stripe = {
    stripe_publishable_key: Rails.application.config.services.stripe[:publishable_key],
    client_id: Rails.application.config.services.stripe[:client_id],
    secret_key: Rails.application.config.services.stripe[:client_secret]
  }

  Stripe.client_id = Rails.application.config.services.stripe[:client_id]
  Stripe.api_key = Rails.application.config.services.stripe[:client_secret]
end

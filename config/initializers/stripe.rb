require 'stripe'

if Rails.application.secrets[:stripe_secret_key].present?
  Rails.configuration.stripe = {
    stripe_publishable_key: Rails.application.secrets[:stripe_publishable_key],
    client_id: Rails.application.secrets[:stripe_client_id],
    secret_key: Rails.application.secrets[:stripe_secret_key]
  }

  Stripe.api_key = Rails.application.secrets[:stripe_secret_key]
  Stripe.client_id = Rails.application.secrets[:stripe_client_id]
end

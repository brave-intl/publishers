# Rails.configuration.to_prepare:
# Run after the initializers are run for all Railties (including the application itself), but before eager loading and the middleware stack is built.
# More importantly, will run upon every request in development, but only once (during boot-up) in production and test.
Rails.configuration.to_prepare do
  Gemini.api_base_uri = Rails.application.config.services.gemini[:base_uri]
  Gemini.client_id = Rails.application.config.services.gemini[:client_id]
  Gemini.client_secret = Rails.application.config.services.gemini[:client_secret]
end

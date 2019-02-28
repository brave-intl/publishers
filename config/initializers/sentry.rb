if %w(production staging).include?(Rails.env)
  require "raven"
  Raven.configure do |config|
    config.dsn = ENV["SENTRY_DSN"] || raise
    config.environments = %w(production staging)
    config.release = ENV["HEROKU_RELEASE_VERSION"]
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end

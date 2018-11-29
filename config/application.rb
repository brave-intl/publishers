require_relative "boot"

require "rails/all"

# Have to require this middleware
# https://github.com/rails/rails/issues/25525
require_relative 'middlewares/http_header_middleware'

# Require the gems listed in Gemfile, including any gems
# you"ve limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Publishers
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.middleware.use HttpHeaderMiddleware

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths += %W(#{config.root}/app/services/ #{config.root}/app/validators/ #{config.root}/lib/devise)

    config.exceptions_app = routes

    if Rails.application.secrets[:log_verbose].present?
      config.log_level = :debug
    else
      config.log_level = :info
    end

    config.lograge.enabled = true

    config.time_zone = "Pacific Time (US & Canada)"
    config.active_record.default_timezone = :local
  end
end

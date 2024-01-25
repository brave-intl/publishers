require_relative "boot"

require "rails/all"

require_relative "middlewares/http_header_middleware"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Publishers
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.pub_secrets = config_for(:secrets) # this line loads the config/secrets.yml file and store it in this namespace
    # Raise error when a before_action's only/except options reference missing actions
    config.action_controller.raise_on_missing_callback_actions = false

    config.middleware.insert 0, Rack::UTF8Sanitizer
    config.middleware.use HttpHeaderMiddleware
    config.middleware.use Rack::Deflater

    config.active_job.queue_adapter = :sidekiq

    config.eager_load_paths += %W[#{config.root}/app/services/ #{config.root}/lib #{config.root}/app/validators/ #{config.root}/lib/devise #{config.root}/app/jobs/payout/concerns/]

    config.exceptions_app = routes

    config.log_level = if Rails.configuration.pub_secrets[:log_verbose].present?
      :debug
    else
      :info
    end

    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"
    config.active_record.belongs_to_required_by_default = false

    config.time_zone = "Pacific Time (US & Canada)"
    config.active_record.default_timezone = :local

    config.active_storage.queues.analysis = :low
    config.active_storage.queues.purge = :low
    config.ssl_options = {redirect: {exclude: ->(request) { request.path =~ /health-check/ }}}

    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    #    config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]
    #    config.i18n.default_locale = :en

    config.services = config_for(:services)

    # Let's ensure that our generators make a UUID as default
    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end

    config.after_initialize do
      commit = `git rev-parse HEAD`.chomp
      url = "https://github.com/brave-intl/publishers/commits/#{commit}"
      message = "✅ Successfully Initialized #{url} in Creators' #{Rails.env}"
      SlackMessenger.new(message: message).perform
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure ActiveRecord Encryption
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA1
    config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true
    config.active_record.encryption.primary_key = Rails.configuration.pub_secrets[:active_record_encryption_primary_key]
    config.active_record.encryption.deterministic_key = Rails.configuration.pub_secrets[:active_record_encryption_deterministic_key]
    config.active_record.encryption.key_derivation_salt = Rails.configuration.pub_secrets[:active_record_encryption_key_derivation_salt]
  end
end

require "active_support/core_ext/integer/time"
require "newrelic_rpm"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Verifies that versions and hashed value of the package contents in the project's package.json
  # config.webpacker.check_yarn_integrity = false

  # Allow images from CDN
  config.action_dispatch.default_headers = {
    "Access-Control-Allow-Origin" => "https://rewards.bravesoftware.com",
    "Access-Control-Request-Method" => "GET",
    "Access-Control-Allow-Headers" => "Origin, X-Requested-With, Content-Type, Accept, Authorization",
    "Access-Control-Allow-Methods" => "GET",
    "X-Frame-Options" => "DENY",
    "X-Content-Type-Options" => "nosniff",
    "Referrer-Policy" => "same-origin",
    "Strict-Transport-Security" => "max-age=31536000; includeSubDomains; preload",
    "Cross-Origin-Opener-Policy" => "same-origin",
    "Cross-Origin-Resource-Policy" => "same-origin"
  }

  # Compress JavaScripts and CSS.
  # config.assets.js_compressor = Uglifier.new(harmony: true, compress: { unused: false })
  config.assets.js_compressor = :terser

  config.cache_store = :redis_cache_store, {
    url: Rails.configuration.pub_secrets[:redis_url],
    connect_timeout: 30, # Defaults to 20 seconds
    read_timeout: 5, # Defaults to 1 second
    write_timeout: 10, # Defaults to 1 second
    error_handler: ->(method:, returning:, exception:) {
      # Report errors to Sentry as warnings
      NewRelic::Agent.notice_error(exception, level: "warning",
                                   tags: { method: method, returning: returning })
    }
  }

  require "connection_pool"
  REDIS = ConnectionPool.new(size: 5) { Redis.new }

  # SESSION STORE
  config.session_store :redis_session_store,
                       key: "_publishers_session",
                       redis: {
                         client: Redis.new(url: Rails.configuration.pub_secrets[:redis_url]),
                         expire_after: 120.minutes,
                         key_prefix: 'publishers:session:'
                       }

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "publishers_#{Rails.env}"
  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: Rails.configuration.pub_secrets[:url_host] }

  # SMTP mailer settings (Sendgrid)
  config.action_mailer.smtp_settings = {
    port: Rails.configuration.pub_secrets[:smtp_server_port],
    address: Rails.configuration.pub_secrets[:smtp_server_address],
    user_name: "apikey", # see https://sendgrid.com/docs/API_Reference/SMTP_API/integrating_with_the_smtp_api.html
    password: Rails.configuration.pub_secrets[:sendgrid_api_key],
    domain: Rails.configuration.pub_secrets[:url_host],
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.delivery_method = :smtp

  # Use S3 for storage
  config.active_storage.service = :amazon_internal_bucket

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

  config.after_initialize do
    # Enable this if rotating keys for encrypted fields
    # Util::AttrEncrypted.monkey_patch_old_key_fallback
  end

  # End Brave customizations

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = false

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"]&.present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
                                       .tap { |logger| logger.formatter = ::Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Info include generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). Use "debug"
  # for everything.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  config.cache_classes = true
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "publishers_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

    # Verifies that versions and hashed value of the package contents in the project's package.json
    # config.webpacker.check_yarn_integrity = false
    # Allow images from CDN
    config.action_dispatch.default_headers = {
       "Access-Control-Allow-Origin" => "https://0.0.0.0:3000",
       "Access-Control-Request-Method" => "GET",
       "Access-Control-Allow-Headers" => "Origin, X-Requested-With, Content-Type, Accept, Authorization",
       "Access-Control-Allow-Methods" => "GET",
       "Permissions-Policy" => "interest-cohort=()"
    }

    config.cache_store = :redis_cache_store, {
       url: Rails.configuration.pub_secrets[:redis_url],
       error_handler: ->(method:, returning:, exception:) { raise exception }
    }

    require "connection_pool"
    REDIS = ConnectionPool.new(size: 5) { Redis.new }

    # SESSION STORE
    config.session_store :redis_session_store,
       key:  "_publishers_session",
       redis: {
       client: Redis.new(url: Rails.configuration.pub_secrets[:redis_url]),
       expire_after: 30.days,
       key_prefix: 'publishers:session:'
    }

    config.action_mailer.default_url_options = { host: "localhost", protocol: "https" }
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true

    config.i18n.load_path += Dir["#{Rails.root}/config/locales/**/*.{rb,yml}"]
    config.i18n.default_locale = :en
    config.assets.debug = true

    # Use an evented file watcher to asynchronously detect changes in source code,
    # routes, locales, etc. This feature depends on the listen gem.
    config.file_watcher = ActiveSupport::EventedFileUpdateChecker

    # Resolves docker error "Cannot render console from 172.21.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1"
    config.web_console.whitelisted_ips = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    config.logger = ActiveSupport::Logger.new(config.paths["log"].first, 1, 50.megabytes)
    config.log_level = :debug
    # config.after_initialize do
       # Bullet.enable = true
       # Bullet.rails_logger = true
       # Enable this if rotating keys for encrypted fields
       # Util::AttrEncrypted.monkey_patch_old_key_fallback
     # end

    # End brave customizations


  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  # if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = false
    config.action_controller.enable_fragment_cache_logging = true

    #config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  # else
  #   config.action_controller.perform_caching = false

  #   config.cache_store = :null_store
  # end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.hosts << "web:3000"
  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
end


# frozen_string_literal: true

ruby "~> 3.0.2"

source "https://rubygems.org"

rails_version = "7.1.2"
gem "rails", rails_version
gem "rails-html-sanitizer", "1.6.0"
gem "railties", rails_version

gem "rack", "3.0.8"

# All things countries
gem "countries"

# Serialize models for JSON APIs
gem "active_model_serializers", "~> 0.10.0"

# For bulk updates/imports
gem "activerecord-import", "~> 1.5.1"

# Allowing for URI templates, for HTTP clients
gem "addressable", "~> 2.8"

gem "activerecord-postgres_enum"

# Use AWS gem for s3 uploads
gem "aws-sdk-s3", "~> 1.141.0"

gem "bootstrap", "4.6.2"

gem "brotli", "~> 0.4.0"

# Authorization
gem "cancancan", "~> 3.5.0"

gem "connection_pool", "~> 2.4"

# Authentication
gem "devise", "~> 4.9.2"

gem "dnsruby", "~> 1.70", require: false
gem "domain_name"

# HTTP library wrapper
gem "faraday", "2.7.10"
gem "faraday-retry", "2.2.0"

gem "ffi"

gem "font-awesome-rails", "~> 4.7.0.4"

gem "google-protobuf", "~> 3.25.1"

# Make logs less mad verbose
gem "lograge", "~> 0.14.0"

# Dependency for rails
gem "nokogiri", ">= 1.15.4"

# Open Graph tag
gem "meta-tags", "~> 2.19.0"

gem "newrelic_rpm", "~> 9.6.0"

gem "omniauth-rails_csrf_protection", "~> 1.0.1"
# Oauth client for google / youtube
gem "omniauth-google-oauth2", "~> 1.1.1"

# Oauth client for twitch
gem "omniauth-twitch", "~> 1.2.0"

# Oauth client for twitter
gem "omniauth-twitter2"

# OAuth client for Vimeo
gem "omniauth-vimeo", github: "beanieboi/omniauth-vimeo", ref: "0f855fd3437061fa2d343c1b6036bd9472c0edd1"

# OAuth client for Reddit
gem "omniauth-reddit", git: "https://github.com/brave-intl/omniauth-reddit.git", branch: "master"

# OAuth client for GitHub
gem "omniauth-github", "~> 2.0.1"

# Model record auditing
gem "paper_trail", "~> 15.1.0"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"

# Easy CSS-sthled emails
gem "premailer-rails", "~> 1.12.0", require: false

# Implementation of PublicSuffix
gem "public_suffix", "~> 5.0.1"

# Puma as app server
gem "puma", "~> 6.4.0"

# Make cracking a little bit harder
gem "rack-attack", github: "rack/rack-attack", branch: "main"

gem "rails-i18n", "~> 7.0.6"

# I love captchas
gem "recaptcha", "~> 5.16.0", require: "recaptcha/rails"

# Cache with Redis
gem "redis", "~> 5.0.6"
gem "redis-session-store"

gem "render_async", "~> 2.1.8"

# For ruby 3
gem "rexml"

# Generate QR codes for TOTP 2fa
gem "rqrcode", "~> 2.2.0"

# SCSS for stylesheets
gem "sass-rails", ">= 6"

# Sendgrid mail service
gem "sendgrid-ruby", "~> 6.6.2"

gem "terser"

# Exception logging
# We don't use anymore
# gem "sentry-raven", "~> 2.11.2", require: false

# Async job processing
gem "sidekiq", "~> 7.2.0"

gem "sidekiq-scheduler", "~> 5.0.3"
gem "sidekiq-throttled", "~> 1.1.0"

# slim for view templates
gem "slim-rails", "3.6.3"

gem "ssrf_filter", "1.1.2"

gem "strong_migrations"

# U2F for 2-factor auth
gem "u2f", "~> 1.0"
gem "webauthn"

# One-time passwords for 2fa
gem "rotp", "~> 6.3.0"

gem "shakapacker", "7.1.0"

# pagination support for models
gem "will_paginate"

# YouTube API client
gem "yt", "~> 0.33.0"

gem "zeitwerk", "~> 2.6.6"
gem "zendesk_api", "~> 3.0.5"

gem "activerecord-nulldb-adapter", github: "ghiculescu/nulldb", branch: "rails-7-1"

gem "wasm-thumbnail-rb", git: "https://github.com/brave-intl/wasm-thumbnail.git", tag: "0.0.5", glob: "wasm-thumbnail-rb/*.gemspec"
gem "wasmer", git: "https://github.com/wasmerio/wasmer-ruby.git", ref: "dab7d537748ce410c660c3fe683df4a2af369f82"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "sprockets-rails", "3.4.2"
gem "sprockets", "4.2.1"

gem "eth", "~> 0.4"
gem "rbnacl"
gem "base58"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen", "~> 3.5"

  # TODO add this back in after rails 7.1 officially drops
  # gem "bullet"

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"

  # gem "spring"
  # gem "spring-watcher-listen", "~> 2.0.0"

  # i18n-tasks helps you find and manage missing and unused translations.
  gem "i18n-tasks", "~> 1.0.12"
end

group :test do
  # Clean state in-between tests which modify the DB
  gem "database_cleaner"
  # API recording and playback
  gem "vcr"
  gem "webmock", "~> 3.0"
  gem "rails-controller-testing"

  # Image information library
  gem "fastimage", "~> 2.2.5"
end

group :development, :test do
  # Create a temporary table-backed ActiveRecord model
  gem "temping"
  gem "pry"
  gem "pry-stack_explorer", "~> 0.6.1"
  gem "byebug"
  gem "pry-byebug"

  # Code formatting
  gem "standard"

  # Static security vulnerability scanner
  gem "brakeman"
  # Vulnerabilities
  gem "bundler-audit", require: false
  gem "capybara"
  gem "minitest"
  gem "minitest-retry"
  gem "minitest-rails", github: "brave-intl/minitest-rails", branch: "rails71"
  gem "mocha", require: false
  gem "simplecov", require: false, group: :test
  gem "selenium-webdriver", "~> 4.12"
  gem "solargraph"
  gem "dotenv-rails", "2.8.1"
end

gem "importmap-rails", "~> 1.1"

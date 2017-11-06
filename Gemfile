# frozen_string_literal: true
source "https://rubygems.org"

# Serialize models for JSON APIs
gem "active_model_serializers", "~> 0.10.0"

# Encrypt DB data at rest
gem "attr_encrypted", "~> 3.0.0"

gem "bootstrap-sass", "~> 3.3.6"

# Authentication
gem "devise", "~> 4.2.0"

gem "email_validator", "~> 1.6"

# HTTP library wrapper
gem "faraday", "~> 0.9.2", require: false

# Make logs less mad verbose
gem "lograge", "~> 0.4"

# Dependency for rails
gem "nokogiri", "~> 1.8.1"

# Oauth client for google / youtube
gem "omniauth-google-oauth2", "~> 0.5.2"

# Model record auditing
gem "paper_trail", "~> 5.2.2"

# postgresql as database for Active Record
gem "pg", "~> 0.18"

# Phone number validation
gem "phony_rails", "~> 0.14"

# Easy CSS-sthled emails
gem "premailer-rails", "~> 1.9.4", require: false

# Puma as app server
gem "puma", "~> 3.0"

gem "rails", "~> 5.0.0", ">= 5.0.0.1"

# Cache with Redis
gem "redis-rails", "~> 5"

# SCSS for stylesheets
gem "sass-rails", "~> 5.0"

# Exception logging
gem "sentry-raven", "~> 2.1", require: false

# Async job processing
gem "sidekiq", "~> 4.2"

gem "sidekiq-scheduler", "~> 2.0"

# slim for view templates
gem "slim-rails", "~> 3.1"

# Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

# clipboard.js for rails
gem "clipboard-rails"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
end

group :development, :staging do
  # Offline domain normalization
  gem "domain_name", require: false

  # Offline DNS verification
  gem "dnsruby", require: false
end

group :development do
  # Vulnerabilities
  gem "bundler-audit", require: false
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
  gem "listen", "~> 3.0.5"
  gem "pry-byebug", require: false
  gem "rubocop", require: false
  # gem "spring"
  # gem "spring-watcher-listen", "~> 2.0.0"

  # i18n-tasks helps you find and manage missing and unused translations.
  gem 'i18n-tasks', '~> 0.9.12'
end

group :test do
  # Clean state in-between tests which modify the DB
  gem "database_cleaner"

  gem "webmock", "~> 3.0"
end

group :production do
  # App monitoring
  gem "newrelic_rpm", "~> 3.16"
end

group :development, :test do
  # Sweet REPL. To use, drop in "binding.pry" anywhere in code.
  gem "pry"
end

group :production, :staging do
  # Make cracking a little bit harder
  gem "rack-attack", "~> 5.0"

  # I love captchas
  gem "recaptcha", "~> 3.3", require: "recaptcha/rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.3.3"

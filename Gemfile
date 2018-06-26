# frozen_string_literal: true
source "https://rubygems.org"

# Rate limit ActiveJob
gem "activejob-traffic_control"

# Serialize models for JSON APIs
gem "active_model_serializers", "~> 0.10.0"

# ActiveRecord Session store for server side storage of session data
gem 'activerecord-session_store'

# Pagination
gem "api-pagination"

# Encrypt DB data at rest
gem "attr_encrypted", "~> 3.1.0"

gem "bootstrap", "~> 4.1.1"

# browser details
gem 'browser'

# Authorization
gem 'cancancan'

# Authentication
gem "devise", "~> 4.2.0"

gem "dnsruby", "~> 1.60.0", require: false

gem "email_validator", "~> 1.6"

# HTTP library wrapper
gem "faraday", "~> 0.9.2", require: false

# For building complex JSON objects
gem 'jbuilder', '~> 2.7.0'

# Make logs less mad verbose
gem "lograge", "~> 0.4"

# Dependency for rails
gem "nokogiri", "~> 1.8.2"

# Open Graph tag
gem "meta-tags"

# Oauth client for google / youtube
gem "omniauth-google-oauth2", "~> 0.5.2"

# Oauth client for google / youtube
gem "omniauth-twitch"

# Model record auditing
gem "paper_trail", "~> 5.2.2"

# postgresql as database for Active Record
gem "pg", "~> 0.18"

# Phone number validation
gem "phony_rails", "~> 0.14"

# Easy CSS-sthled emails
gem "premailer-rails", "~> 1.9.4", require: false

# Implementation of PublicSuffix
gem 'public_suffix', '~> 3.0.2'

# Puma as app server
gem "puma", "3.10"

# Make cracking a little bit harder
gem "rack-attack", "~> 5.0"

gem "rails", "~> 5.0.0", ">= 5.0.0.1"

# I love captchas
gem "recaptcha", "~> 3.3", require: "recaptcha/rails"

# Markdown support
gem "redcarpet"

# Cache with Redis
gem "redis-rails", "~> 5"

gem "redis-store", "~> 1.4.0"

# Generate QR codes for TOTP 2fa
gem "rqrcode", "~> 0.10"

# SCSS for stylesheets
gem "sass-rails", "~> 5.0"

# Sendgrid mail service
gem "sendgrid-ruby"

# Exception logging
gem "sentry-raven", "~> 2.1", require: false

# Async job processing
gem "sidekiq", "~> 4.2"

gem "sidekiq-scheduler", "~> 2.0"

# Used by sendgrid-ruby. Forcing an update due to a security concern
gem 'sinatra', '~> 2.0.2'

# slim for view templates
gem "slim-rails", "~> 3.1"

# U2F for 2-factor auth
gem "u2f", "~> 1.0"

# One-time passwords for 2fa
gem "rotp", "~> 3.3"

gem 'webpacker', '~> 3.2'

# pagination support for models
gem "will_paginate"

group :development, :staging do
  # Offline domain normalization
  gem "domain_name", require: false
end

group :development do
  # Vulnerabilities
  gem "bundler-audit", require: false

  # Static security vulnerability scanner
  gem "brakeman"

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
  gem "listen", "~> 3.0.5"
  gem "rubocop", require: false
  # gem "spring"
  # gem "spring-watcher-listen", "~> 2.0.0"

  # i18n-tasks helps you find and manage missing and unused translations.
  gem "i18n-tasks", "~> 0.9.12"
end

group :test do
  # Clean state in-between tests which modify the DB
  gem "database_cleaner"

  # Locking to 5.10.3 to workaround issue in 5.11.1 (https://github.com/seattlerb/minitest/issues/730)
  gem "minitest", "5.10.3"

  # API recording and playback
  gem "vcr"

  gem "webmock", "~> 3.0"

  gem "rails-controller-testing"
end

group :production do
  # App monitoring
  gem "newrelic_rpm", "~> 3.16"
end

group :development, :test do
  gem "pry"
  gem "byebug"
  gem "pry-byebug", require: false

  gem "mocha"
  gem "minitest-rails-capybara"
  gem "capybara-selenium"
  gem "chromedriver-helper"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.3.7"

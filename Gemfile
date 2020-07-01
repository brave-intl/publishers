# frozen_string_literal: true

ruby "2.7.1"

source "https://rubygems.org"

# Serialize models for JSON APIs
gem "active_model_serializers", "~> 0.10.0"

# ActiveRecord Session store for server side storage of session data
gem 'activerecord-session_store', '~> 1.1', '>= 1.1.3'

# Allowing for URI templates, for HTTP clients
gem 'addressable', '~> 2.6'

# Encrypt DB data at rest
gem "attr_encrypted", "~> 3.1.0"

# Integration with Matomo Piwik
gem 'autometal-piwik', :require => 'piwik', git: "https://github.com/matomo-org/piwik-ruby-api.git", branch: "master"

# Use AWS gem for s3 uploads
gem 'aws-sdk-s3', require: false

gem "bootstrap", ">= 4.3.1"

gem 'brotli', "~> 0.2.3"

# Authorization
gem 'cancancan',  "~> 3.1.0"

# Authentication
gem "devise", "~> 4.7.1"

gem "dnsruby", "~> 1.60.0", require: false

# HTTP library wrapper
gem "faraday", "~> 0.17.3"

gem "font-awesome-rails", "~> 4.7.0.4"

gem 'google-protobuf', "~> 3.12.0"

# Make logs less mad verbose
gem "lograge", "~> 0.4"

# Dependency for rails
gem "nokogiri", "~> 1.10.9"

# Open Graph tag
gem "meta-tags", "~> 2.13.0"

# Image conversion library
gem 'mini_magick', "~> 4.10.1"

gem "newrelic_rpm", "~> 6.7.0.359"

gem 'omniauth-rails_csrf_protection', '~> 0.1.2'
# Oauth client for google / youtube
gem "omniauth-google-oauth2", "~> 0.8.0"

# Oauth client for twitch
gem "omniauth-twitch", "~> 1.1.0"

# Oauth client for twitter
gem "omniauth-twitter", "~> 1.4.0"

# OAuth client for Vimeo
gem "omniauth-vimeo", "~> 2.0.1"

# OAuth client for Reddit
gem 'omniauth-reddit', :git => 'https://github.com/dlipeles/omniauth-reddit.git', :branch => "master"

# OAuth client for GitHub
gem "omniauth-github", "~> 1.4.0"

# Model record auditing
gem "paper_trail", "~> 10.3.1"

# postgresql as database for Active Record
gem "pg", "~> 0.18"

# Easy CSS-sthled emails
gem "premailer-rails", "~> 1.10.3", require: false

# Implementation of PublicSuffix
gem 'public_suffix', '~> 4.0.3'

# Puma as app server
gem "puma", "~> 4.3.5"

# Make cracking a little bit harder
gem "rack-attack", "~> 5.0"

gem 'railties', "~> 6.0.3.1"

gem "rails", "~> 6.0.3"
gem 'rails-i18n', '~> 6.0.0'

# I love captchas
gem "recaptcha", "~> 3.3", require: "recaptcha/rails"

# Cache with Redis
gem 'redis', '~> 4.2.1'

# Generate QR codes for TOTP 2fa
gem "rqrcode", "~> 0.10"

# SCSS for stylesheets
gem "sass-rails", "~> 5.0"

# Sendgrid mail service
gem "sendgrid-ruby", "~> 6.2.1"

# Exception logging
gem "sentry-raven", "~> 2.11.2", require: false

# Async job processing
gem "sidekiq", "~> 6.0.7"

gem "sidekiq-scheduler", "~> 3.0.1"

# slim for view templates
gem "slim-rails", "~> 3.1"

# U2F for 2-factor auth
gem "u2f", "~> 1.0"

# One-time passwords for 2fa
gem "rotp", "~> 3.3"

gem 'webpacker', '~> 4.0.7'

# pagination support for models
gem "will_paginate"

# YouTube API client
gem 'yt', "~> 0.33.0"

gem "zeitwerk", '~> 2.3.0'
gem "zendesk_api", "~> 1.26.0"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'listen', '~> 3.2'

  gem 'bullet'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"

  # gem "spring"
  # gem "spring-watcher-listen", "~> 2.0.0"

  # i18n-tasks helps you find and manage missing and unused translations.
  gem "i18n-tasks", "~> 0.9.12"
end

group :test do
  # Clean state in-between tests which modify the DB
  gem "database_cleaner"
  # API recording and playback
  gem "vcr"
  gem "webmock", "~> 3.0"
  gem "rails-controller-testing"
end

group :development, :test do
  # Create a temporary table-backed ActiveRecord model
  gem 'temping'
  gem 'rubocop-airbnb'

  gem "pry"
  gem 'pry-stack_explorer', '~> 0.4.9.3'
  gem "byebug"
  gem "pry-byebug", require: false

  # Static security vulnerability scanner
  gem "brakeman"
  # Vulnerabilities
  gem "bundler-audit", require: false
  gem 'capybara'
  gem 'minitest'
  gem 'minitest-rails'
  gem "mocha"
  gem "chromedriver-helper"
  gem 'simplecov', require: false, group: :test
  gem 'selenium-webdriver', "~> 3.142.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

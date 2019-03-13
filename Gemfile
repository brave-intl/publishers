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

# Integration with Matomo Piwik
gem 'autometal-piwik', :require => 'piwik', git: "https://github.com/matomo-org/piwik-ruby-api.git", branch: "master"

# Use AWS gem for s3 uploads
gem 'aws-sdk-s3', require: false

gem "bootstrap", ">= 4.3.1"

# browser details
gem 'browser'

# Authorization
gem 'cancancan'

# Authentication
gem "devise", "~> 4.4.3"

gem "dnsruby", "~> 1.60.0", require: false

gem "email_validator", "~> 1.6"

# HTTP library wrapper
gem "faraday", "~> 0.9.2", require: false

gem "font-awesome-rails", "~> 4.7.0.4"

# For building complex JSON objects
gem 'jbuilder', '~> 2.7.0'

# Make logs less mad verbose
gem "lograge", "~> 0.4"

# Dependency for rails
gem "nokogiri", "~> 1.8.4"

# Open Graph tag
gem "meta-tags"

# Image conversion library
gem 'mini_magick'

# Oauth client for google / youtube
gem "omniauth-google-oauth2", "~> 0.5.2"

# Oauth client for twitch
gem "omniauth-twitch"

# Oauth client for twitter
gem "omniauth-twitter"

# Model record auditing
gem "paper_trail", "~> 10.1.0"

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

gem 'railties', "~> 5.2.0"

gem "rails", "~> 5.2.2.rc1"

# I love captchas
gem "recaptcha", "~> 3.3", require: "recaptcha/rails"

# Cache with Redis
gem 'redis', '~> 4.0.1'

# Generate QR codes for TOTP 2fa
gem "rqrcode", "~> 0.10"

# SCSS for stylesheets
gem "sass-rails", "~> 5.0"

# Sendgrid mail service
gem "sendgrid-ruby"

# Exception logging
gem "sentry-raven", "~> 2.1", require: false

# Async job processing
gem "sidekiq"

gem "sidekiq-scheduler", "~> 2.2.2"

# Used by sendgrid-ruby. Forcing an update due to a security concern
gem 'sinatra', '~> 2.0.2'

# slim for view templates
gem "slim-rails", "~> 3.1"

# U2F for 2-factor auth
gem "u2f", "~> 1.0"

# One-time passwords for 2fa
gem "rotp", "~> 3.3"

gem 'webpacker', '~> 4.0.0.rc.2'

# pagination support for models
gem "will_paginate"

# YouTube API client
gem 'yt'

group :development, :staging do
  # Offline domain normalization
  gem "domain_name", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"

  # Static security vulnerability scanner
  gem "brakeman"
  gem "pry"
  gem 'pry-stack_explorer', '~> 0.4.9.3'
  gem "byebug"
  gem "pry-byebug", require: false

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
  gem "brakeman"
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
  # Create a temporary table-backed ActiveRecord model
  gem 'temping'
  # Vulnerabilities
  gem "bundler-audit", require: false
  gem "mocha"
  gem 'minitest-rails-capybara', '~> 3.0.1'
  gem "capybara-selenium"
  gem "chromedriver-helper"
  gem 'simplecov', require: false, group: :test
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.4.5"

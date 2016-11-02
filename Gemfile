# frozen_string_literal: true
source "https://rubygems.org"

# Serialize models for JSON APIs
gem "active_model_serializers", "~> 0.10.0"

# Encrypt DB data at rest
gem "attr_encrypted", "~> 3.0.0"

gem "aws-sdk", "~> 2", require: false

gem "bitcoin-ruby", "~> 0.0.8", require: false

gem "bootstrap-sass", "~> 3.3.6"

# Authentication
gem "devise", "~> 4.2.0"

gem "docusign_rest", "~> 0.1.1"

gem "email_validator", "~> 1.6"

# HTTP library wrapper
gem "faraday", "~> 0.9.2", require: false

gem "gpgme", "~> 2.0", require: false

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

# Async job processing
gem "sidekiq", "~> 4.2"

gem "sidekiq-scheduler", "~> 2.0"

# slim for view templates
gem "slim-rails", "~> 3.1"

# Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

# gem "therubyracer", platforms: :ruby

# Use jquery as the JavaScript library
# gem "jquery-rails"
# JSON APIs
# gem "jbuilder", "~> 2.5"
# Redis adapter to run Action Cable in production
# gem "redis", "~> 3.0"
# ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
end

group :development, :staging do
  gem "domain_name", require: false
  gem "dnsruby", require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
  gem "listen", "~> 3.0.5"
  gem "pry", require: false
  gem "pry-byebug", require: false
  gem "rubocop", require: false
  # gem "spring"
  # gem "spring-watcher-listen", "~> 2.0.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.3.1"

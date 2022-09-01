# typed: strict

# Be sure to restart your server when you modify this file.

# Underlying setup found in https://github.com/rails/activerecord-session_store/blob/master/lib/tasks/database.rake
ENV["SESSION_DAYS_TRIM_THRESHOLD"] = "1"
Rails.application.config.session_store :active_record_store, key: "_publishers_session"

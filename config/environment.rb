# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

if Rails.configuration.pub_secrets[:api_eyeshade_base_uri].present?
  puts "Eyeshade API: #{ENV["API_EYESHADE_BASE_URI"]}"
else
  ENV["API_EYESHADE_OFFLINE"] = "1"
end

Publishers::Application.default_url_options = Publishers::Application.config.action_mailer.default_url_options

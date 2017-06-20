# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

if Rails.application.secrets[:api_eyeshade_base_uri].present?
  puts "Eyeshade API: #{ENV['API_EYESHADE_BASE_URI']}"
else
  ENV["API_EYESHADE_OFFLINE"] = "1"
end

if Rails.application.secrets[:api_ledger_base_uri].present?
  puts "Ledger API: #{ENV['API_LEDGER_BASE_URI']}"
else
  ENV["API_LEDGER_OFFLINE"] = "1"
end

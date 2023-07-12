# typed: strict

Yt.configure do |config|
  config.api_key = Rails.application.credentials[:youtube_api_key]
end

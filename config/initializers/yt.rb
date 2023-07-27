# typed: strict

Yt.configure do |config|
  config.api_key = Rails.configuration.pub_secrets[:youtube_api_key]
end

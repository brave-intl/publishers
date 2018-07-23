Yt.configure do |config|
  config.api_key = Rails.application.secrets[:youtube_api_key]
end
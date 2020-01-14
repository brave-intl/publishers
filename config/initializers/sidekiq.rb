# https://github.com/mperham/sidekiq/wiki/Using-Redis#using-an-initializer
Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets[:redis_url], network_timeout: 5 }
end

# Must define both configure_server and configure_client
Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets[:redis_url], network_timeout: 5 }
end

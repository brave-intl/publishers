# https://github.com/mperham/sidekiq/wiki/Using-Redis#using-an-initializer
if Rails.application.secrets[:redis_url].present?
  Sidekiq.configure_server do |config|
    config.redis = { url: Rails.application.secrets[:redis_url], size: 40, network_timeout: 5 }
  end

  # Must define both configure_server and configure_client
  Sidekiq.configure_client do |config|
    config.redis = { url: Rails.application.secrets[:redis_url], size: 40, network_timeout: 5 }
  end

  # Prevent user's sessions from being overwritten so you can be logged in and also have the Sidekiq UI open.
  # https://github.com/mperham/sidekiq/wiki/Monitoring#sessions-being-lost
  require 'sidekiq/web'
  Sidekiq::Web.set :sessions, false
end

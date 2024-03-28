OmniAuth.config.logger = Rails.logger

OmniAuth.config.full_host = lambda do |env|
  Rails.configuration.pub_secrets[:creators_full_host]
end

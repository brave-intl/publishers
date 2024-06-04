OmniAuth.config.logger = Rails.logger

# OmniAuth.config.before_request_phase do
#   ...
# end

if !Rails.env.test?
  OmniAuth.config.full_host = lambda do |env|
    Rails.configuration.pub_secrets[:creators_full_host]
  end
end

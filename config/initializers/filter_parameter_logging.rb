# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i(authentication_token bitcoin_address uphold_code uphold_access_parameters password token verification_token)

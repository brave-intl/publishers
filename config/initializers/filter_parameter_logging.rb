# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :authentication_token, :uphold_code, :uphold_access_parameters, :password, :token, :verification_token,
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]

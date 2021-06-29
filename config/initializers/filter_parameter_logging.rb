# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :authentication_token, :uphold_code, :uphold_access_parameters, :password, :token, :verification_token,
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
]

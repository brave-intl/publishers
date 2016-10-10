DocusignRest.configure do |config|
  config.account_id = Rails.application.secrets[:docusign_api_account_id]
  config.api_version = "v2"
  # config.endpoint       = 'https://www.docusign.net/restapi'
  config.username = Rails.application.secrets[:docusign_api_username]
  config.password = Rails.application.secrets[:docusign_api_password]
  config.integrator_key = Rails.application.secrets[:docusign_integrator_key]
end

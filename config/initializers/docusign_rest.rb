DocusignRest.configure do |config|
  # Discover endpoint with DocusignRest::Client #get_login_information
  # Default: "https://demo.docusign.net/restapi"
  if Rails.application.secrets[:docusign_api_endpoint]
    config.endpoint = Rails.application.secrets[:docusign_api_endpoint]
  end
  # Default: "v2"
  if Rails.application.secrets[:docusign_api_version]
    config.api_version = Rails.application.secrets[:docusign_api_version]
  end
  # e.g. 12345678
  config.account_id = Rails.application.secrets[:docusign_api_account_id]
  config.username = Rails.application.secrets[:docusign_api_username]
  config.password = Rails.application.secrets[:docusign_api_password]
  config.integrator_key = Rails.application.secrets[:docusign_integrator_key]
end

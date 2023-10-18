# typed: ignore

# To set authorization for the API, configure ENV["API_AUTH_TOKEN"] and
# api_auth_token ENV["API_IP_WHITELIST"] (see secrets.yml)
class Api::Nextv1::BaseController < ActionController::API
  before_action :log_full_request, if: -> { Rails.configuration.pub_secrets[:log_api_requests] }

  before_action :authenticate_publisher!
end

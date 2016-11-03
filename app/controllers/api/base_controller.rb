# To set authorization for the API, configure ENV["API_AUTH_TOKEN"] and
# api_auth_token ENV["API_IP_WHITELIST"] (see secrets.yml)
class Api::BaseController < ActionController::API
  before_action :log_full_request, if: -> { !Rails.env.production? }

  API_AUTH_TOKEN = Rails.application.secrets[:api_auth_token].freeze

  if Rails.application.secrets[:api_ip_whitelist]
    API_IP_WHITELIST = Rails.application.secrets[:api_ip_whitelist].split(",").map { |ip_cidr| IPAddr.new(ip_cidr) }.freeze
  else
    API_IP_WHITELIST = [].freeze
  end

  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  private

  # before_action filter to protect API controller actions.
  def authenticate
    (authenticate_ip && authenticate_token) || render_unauthorized
  end

  def authenticate_ip
    return true if API_IP_WHITELIST.blank?
    # Set this in Fastly.
    remote_ip = request.headers["Fastly-Client-IP"].presence || request.remote_ip
    ip_auth_result = API_IP_WHITELIST.any? { |ip_addr| ip_addr.include?(remote_ip) }
    Rails.logger.debug("IP auth result for #{remote_ip}: #{ip_auth_result}")
    ip_auth_result
  end

  def authenticate_token
    return true if API_AUTH_TOKEN.blank?
    authenticate_with_http_token do |token, _options|
      # Compare the tokens in a time-constant manner, to mitigate timing attacks.
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token),
        ::Digest::SHA256.hexdigest(API_AUTH_TOKEN)
      )
    end
  end

  def log_full_request
    http_envs = {}.tap do |envs|
      request.headers.each do |key, value|
        envs[key] = value if key == key.upcase
      end
    end
    Rails.logger.debug("Headers: #{http_envs}")
    Rails.logger.debug("Body: #{request&.raw_post}")
  end

  def render_unauthorized
    render(json: { message: "authentication failed 🎷" }, status: 403)
  end
end

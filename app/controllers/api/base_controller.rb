# To set authorization for the API, configure ENV["API_AUTH_TOKEN"] and
# api_auth_token ENV["API_IP_WHITELIST"] (see secrets.yml)
class Api::BaseController < ActionController::API
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
    puts "request ip: #{request.remote_ip}"
    (authenticate_ip && authenticate_token) || render_unauthorized
  end

  def authenticate_ip
    return true if API_IP_WHITELIST.blank?
    API_IP_WHITELIST.any? { |ip_addr| ip_addr.include?(request.remote_ip) }
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

  def render_unauthorized
    render(json: { message: "authentication failed 🎷" }, status: 403)
  end
end

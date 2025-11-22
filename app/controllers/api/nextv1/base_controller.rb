# typed: ignore

# To set authorization for the API, configure ENV["API_AUTH_TOKEN"] and
# api_auth_token ENV["API_IP_WHITELIST"] (see secrets.yml)
class Api::Nextv1::BaseController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception

  before_action :log_full_request, if: -> { Rails.configuration.pub_secrets[:log_api_requests] }

  before_action :authenticate_publisher!

  before_action :set_csrf_cookie

  def authenticate_publisher!(opts = {})
    opts[:scope] = :publisher
    warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
  end

  def publisher_signed_in?
    !!current_publisher
  end

  def current_publisher
    @current_publisher ||= warden.authenticate(scope: :publisher)
  end

  def publisher_session
    current_publisher && warden.session(:publisher)
  end

  def log_full_request
    http_envs = {}.tap do |envs|
      request.headers.each do |key, value|
        envs[key] = value if key == key.upcase
      end
    end
    Rails.logger.info("Headers: #{http_envs}")
    Rails.logger.info("Body: #{request&.raw_post}")
  end

  private

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = form_authenticity_token
  end
end

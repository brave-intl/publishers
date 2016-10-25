class Api::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  private

  # before_action filter to protect API controller actions.
  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    return true if Rails.application.secrets[:api_auth_token].blank?
    authenticate_with_http_token do |token, _options|
      # Compare the tokens in a time-constant manner, to mitigate timing attacks.
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token),
        ::Digest::SHA256.hexdigest(Rails.application.secrets[:api_auth_token])
      )
    end
  end

  def render_unauthorized
    render(json: { message: "authentication failed 🎷" }, status: 403)
  end
end

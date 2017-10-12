class ApplicationController < ActionController::Base
  if ENV["TARGET_APP_DOMAIN"]
    TARGET_APP_DOMAIN = ENV["TARGET_APP_DOMAIN"].freeze
    Rails.logger.info("Redirecting all requests to #{TARGET_APP_DOMAIN}")
    before_action :ensure_domain
    def ensure_domain
      Rails.logger.info(request.env["HTTP_HOST"])
      return true if request.env["HTTP_HOST"] == TARGET_APP_DOMAIN
      redirect_to "https://#{TARGET_APP_DOMAIN}#{request.path}", status: :moved_permanently
    end
  end

  if Rails.application.secrets[:basic_auth_user] && Rails.application.secrets[:basic_auth_password]
    http_basic_authenticate_with(
      name: Rails.application.secrets[:basic_auth_user],
      password: Rails.application.secrets[:basic_auth_password]
    )
  end

  protect_from_forgery with: :exception

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end

class ApplicationController < ActionController::Base
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

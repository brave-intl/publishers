class BrowserUsersController < ApplicationController
  before_action :authenticate_publisher!
  before_action :protect

  def home
    @browser_user = current_publisher
    @promo_registration = current_publisher.promo_registrations.first
  end

  def accept_tos
    current_publisher.update(agreed_to_tos: Time.now)
    redirect_back(fallback_location: browser_users_home_path)
  end

  def protect
    return if current_publisher&.browser_user?
    redirect_to root_url
  end
end

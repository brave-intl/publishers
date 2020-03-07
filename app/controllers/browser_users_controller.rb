class BrowserUsersController < ApplicationController
  include PromosHelper
  before_action :authenticate_publisher!
  before_action :protect

  def home
    @browser_user = current_publisher
    @promo_registration = current_publisher.promo_registrations.first
  end

  def protect
    if current_publisher.nil? || !current_publisher.browser_user?
      redirect_to root_url and return
    end
  end
end

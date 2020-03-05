class BrowserUsersController < ApplicationController
  before_action :authenticate_publisher! # Will fix this at some point
  before_action :protect

  def home
    @browser_user = current_publisher
  end

  def protect
    if current_publisher.nil? || !current_publisher.browser_user?
      redirect_to root_url and return
    end
  end
end

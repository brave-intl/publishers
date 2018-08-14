class Publishers::SiteBannersController < ApplicationController

  def new
    @site_banner = current_publisher.site_banner || SiteBanner.new
  end

  def create
    p params
    p "what is happening"
    redirect_to(new_publisher_site_banner_path(current_publisher))
  end
end

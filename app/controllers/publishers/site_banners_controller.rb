class Publishers::SiteBannersController < ApplicationController

  def new
    @site_banner = current_publisher.site_banner || SiteBanner.new
  end

  def create
    site_banner = current_publisher.site_banner || SiteBanner.new
    site_banner.update(
      publisher_id: current_publisher.id,
      title: params[:title],
      description: params[:description]
    )

    site_banner.logo.attach(params[:logo]) if params[:logo].present?
    site_banner.background_image.attach(params[:background_image]) if params[:background_image].present?
    redirect_to(new_publisher_site_banner_path(current_publisher))
  end

  def update_logo
    head :ok
  end

  def update_background_image
    head :ok
  end
end

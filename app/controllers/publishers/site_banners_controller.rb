class Publishers::SiteBannersController < ApplicationController
  def new
    @site_banner = current_publisher.site_banner || SiteBanner.new
  end

  def create
    site_banner = current_publisher.site_banner || SiteBanner.new
    donation_amounts = JSON.parse(params[:donation_amounts])
    site_banner.update(
      publisher_id: current_publisher.id,
      title: params[:title],
      donation_amounts: donation_amounts,
      default_donation: donation_amounts[1],
      social_links: params[:social_links],
      description: params[:description]
    )
    head :ok
  end

  def update_logo
    site_banner = current_publisher.site_banner
    update_image(site_banner.logo)
    head :ok
  end

  def update_background_image
    site_banner = current_publisher.site_banner
    update_image(site_banner.background_image)
    head :ok
  end

  private

  def update_image(attachment)
    data_url = params[:image].split(',')[0]
    if data_url.starts_with?("data:image/jpeg")
      content_type = "image/jpeg"
      extension = ".jpg"
    elsif data_url.starts_with?("data:image/png")
      content_type = "image/png"
      extension = ".png"
    else
      # TODO: Throw an exception here
    end
    filename = Time.now.to_s.gsub!(" ", "_").gsub!(":", "_") + current_publisher.id + "_logo"

    file = Tempfile.new([filename, extension])
    File.open(file.path, 'wb') do |f|
      f.write(Base64.decode64(params[:image].split(',')[1]))
    end
    attachment.attach(io: open(file.path),
                      filename: filename,
                      content_type: content_type
                     )
  end
end

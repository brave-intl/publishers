class Publishers::SiteBannersController < ApplicationController

  MAX_IMAGE_SIZE = 700_000

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
      default_donation: donation_amounts.second,
      social_links: params[:social_links].present? ? JSON.parse(params[:social_links]) : {},
      description: params[:description]
    )
    head :ok
  end

  def fetch
    site_banner = current_publisher.site_banner
    data = JSON.parse(site_banner.to_json)
    data[:backgroundImage] = current_publisher.site_banner.read_only_react_property[:backgroundUrl]
    data[:logoImage] = current_publisher.site_banner.read_only_react_property[:logoUrl]
    render(json: data.to_json)
  end

  def update_logo
    if params[:image].length > MAX_IMAGE_SIZE
      # (Albert Wang): We should consider supporting alerts. This might require a UI redesign
      # alert[:error] = "File size too big!"
      head :payload_too_large and return
    end
    site_banner = current_publisher.site_banner
    update_image(site_banner.logo)
    head :ok
  end

  def update_background_image
    if params[:image].length > MAX_IMAGE_SIZE
      # (Albert Wang): We should consider supporting alerts. This might require a UI redesign
      # alert[:error] = "File size too big!"
      head :payload_too_large and return
    end

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

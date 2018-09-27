class Publishers::SiteBannersController < ApplicationController
  include ImageConversionHelper
  before_action :authenticate_publisher!

  MAX_IMAGE_SIZE = 10_00_000

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
    update_image(attachment: site_banner.logo, attachment_type: SiteBanner::LOGO)
    head :ok
  end

  def update_background_image
    if params[:image].length > MAX_IMAGE_SIZE
      # (Albert Wang): We should consider supporting alerts. This might require a UI redesign
      # alert[:error] = "File size too big!"
      head :payload_too_large and return
    end
    site_banner = current_publisher.site_banner
    update_image(attachment: site_banner.background_image, attachment_type: SiteBanner::BACKGROUND)
    head :ok
  end

  private

  def update_image(attachment:, attachment_type:)
    data_url = params[:image].split(',')[0]
    if data_url.starts_with?("data:image/jpeg")
      content_type = "image/jpeg"
      extension = ".jpg"
    elsif data_url.starts_with?("data:image/png")
      content_type = "image/png"
      extension = ".png"
    elsif data_url.starts_with?("data:image/bmp")
      content_type = "image/bmp"
      extension = ".bmp"
    else
      LogException.perform(StandardError.new("Unknown image format:" + data_url), params: {})
      return nil
    end
    filename = Time.now.to_s.gsub!(" ", "_").gsub!(":", "_") + current_publisher.id

    temp_file = Tempfile.new([filename, extension])
    File.open(temp_file.path, 'wb') do |f|
      f.write(Base64.decode64(params[:image].split(',')[1]))
    end

    original_image_path = temp_file.path

    resized_jpg_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: original_image_path,
      attachment_type: attachment_type,
      filename: filename
    )

    begin
      padded_resized_jpg_path = add_padding_to_image(
        source_image_path: resized_jpg_path,
        attachment_type: attachment_type,
      )
    rescue OutsidePaddingRangeError
      LogException.perform(StandardError.new("File size too big for #{attachment_type}"), params: {publisher_id: current_publisher.id})
    end

    new_filename = generate_filename(source_image_path: padded_resized_jpg_path)

    attachment.attach(
      io: open(padded_resized_jpg_path),
      filename: new_filename + ".jpg",
      content_type: "image/jpg"
    )
  end
end

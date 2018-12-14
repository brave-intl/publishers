class Publishers::SiteBannersController < ApplicationController
  include ImageConversionHelper
  before_action :authenticate_publisher!, only: [:create, :update_logo, :update_background]

  MAX_IMAGE_SIZE = 10_000_000

  def show
    if site_banner
      data = site_banner.read_only_react_property
      data[:backgroundImage] = data[:backgroundUrl]
      data[:logoImage] = data[:logoUrl]
      render(json: data.to_json)
    else
      render(json: nil.to_json)
    end
  end

  def update
    if site_banner
      site_banner.update_helper(params[:title], params[:description], params[:donation_amounts], params[:social_links])
      if params[:logo] && params[:logo].length < MAX_IMAGE_SIZE
        site_banner.upload_public_logo(
          image_properties(attachment_type: SiteBanner::LOGO)
        )
      end

      if params[:cover] && params[:cover].length < MAX_IMAGE_SIZE
        site_banner.upload_public_background_image(
          image_properties(attachment_type: SiteBanner::BACKGROUND)
        )
      end
    end
    head :ok
  end

  def set_default_site_banner_mode
    current_publisher.update(default_site_banner_mode: params[:dbm])
  end

  private

  def site_banner
    @site_banner ||= current_publisher.site_banners.find_by(id: params[:id])
  end

  def image_properties(attachment_type:)
    if attachment_type === SiteBanner::LOGO
      data_url = params[:logo].split(',')[0]
    elsif attachment_type === SiteBanner::BACKGROUND
      data_url = params[:cover].split(',')[0]
    end
    if data_url.starts_with?("data:image/jpeg") || data_url.starts_with?("data:image/jpg")
      extension = ".jpg"
    elsif data_url.starts_with?("data:image/png")
      extension = ".png"
    elsif data_url.starts_with?("data:image/bmp")
      extension = ".bmp"
    else
      LogException.perform(StandardError.new("Unknown image format:" + data_url), params: {})
      return nil
    end
    filename = Time.now.to_s.gsub!(" ", "_").gsub!(":", "_") + current_publisher.id

    temp_file = Tempfile.new([filename, extension])
    File.open(temp_file.path, 'wb') do |f|
      if attachment_type === SiteBanner::LOGO
        f.write(Base64.decode64(params[:logo].split(',')[1]))
      elsif attachment_type === SiteBanner::BACKGROUND
        f.write(Base64.decode64(params[:cover].split(',')[1]))
      end
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
        attachment_type: attachment_type
      )
    rescue OutsidePaddingRangeError => e
      logger.error "Outside padding range #{e.message}"
      LogException.perform(StandardError.new("File size too big for #{attachment_type}"), params: {publisher_id: current_publisher.id})
    end

    new_filename = generate_filename(source_image_path: padded_resized_jpg_path)

    {
      io: open(padded_resized_jpg_path),
      filename: new_filename + ".jpg",
      content_type: "image/jpg"
    }
  end
end

class Publishers::SiteBannersController < ApplicationController
  include ImageConversionHelper
  include ActiveStorage::SetCurrent
  before_action :authenticate_publisher!

  MAX_IMAGE_SIZE = 10_000_000

  def show
    if site_banner
      render json: site_banner.read_only_react_property
    else
      render(json: nil.to_json)
    end
  end

  def update
    if site_banner
      site_banner.update_helper(params[:title], params[:description], params[:donation_amounts], params[:social_links])
      if params[:logo] && params[:logo].length < MAX_IMAGE_SIZE
        site_banner.logo.attach(
          image_properties(attachment_type: SiteBanner::LOGO)
        )
        site_banner.save!
      end

      if params[:cover] && params[:cover].length < MAX_IMAGE_SIZE

        site_banner.background_image.attach(
          image_properties(attachment_type: SiteBanner::BACKGROUND)
        )
        site_banner.save!
      end
    end
    head :ok
  rescue MiniMagick::Error
    render status: 400, json: { message: I18n.t('.shared.oh_no') }.to_json
  rescue StandardError => e
    render status: 400, json: { message: e.message }.to_json
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
    temp_file.rewind
    padded_resized_jpg_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: original_image_path,
      attachment_type: attachment_type,
      filename: filename
    )

    new_filename = generate_filename(source_image_path: padded_resized_jpg_path)
    {
      io: open(padded_resized_jpg_path),
      filename: new_filename + ".jpg",
      content_type: "image/jpg",
    }
  end
end

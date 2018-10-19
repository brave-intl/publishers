class Publishers::SiteBannersController < ApplicationController
  include ImageConversionHelper
  include ActionView::Helpers::SanitizeHelper
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_publisher!, only: [:create, :update_logo, :update_background]

  MAX_IMAGE_SIZE = 10_000_000

  def new
    @site_banner = current_publisher.site_banner || SiteBanner.new
  end

  def create
    head 401 and return unless current_publisher.in_brave_rewards_whitelist?
    site_banner = current_publisher.site_banner || SiteBanner.new
    donation_amounts = JSON.parse(sanitize(params[:donation_amounts]))
    site_banner.update(
      publisher_id: current_publisher.id,
      title: sanitize(params[:title]),
      donation_amounts: donation_amounts,
      default_donation: donation_amounts.second,
      social_links: params[:social_links].present? ? JSON.parse(sanitize(params[:social_links])) : {},
      description: sanitize(params[:description])
    )
    head :ok
  end

  def fetch
    if current_publisher.site_banner.present?
      data = current_publisher.site_banner.read_only_react_property
      data[:backgroundImage] = data[:backgroundUrl]
      data[:logoImage] = data[:logoUrl]
      render(json: data.to_json)
    else
      render(json: {}.to_json)
    end
  end

  def update_logo
    head 401 and return unless current_publisher.in_brave_rewards_whitelist?
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
    head 401 and return unless current_publisher.in_brave_rewards_whitelist?
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
        attachment_type: attachment_type
      )
    rescue OutsidePaddingRangeError => e
      logger.error "Outside padding range #{e.msg}"
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

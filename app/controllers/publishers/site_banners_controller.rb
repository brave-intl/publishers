class Publishers::SiteBannersController < ApplicationController
  include ImageConversionHelper
  include ActionView::Helpers::SanitizeHelper
  before_action :authenticate_publisher!, only: [:create, :update_logo, :update_background]

  MAX_IMAGE_SIZE = 10_000_000

  #Fetch Banner by channel_id, if it does not exist create a template banner.
  def fetch
    site_banner = current_publisher.site_banners.where(channel_id: params[:channel_id]).first
    if site_banner.present?
      data = site_banner.read_only_react_property
      data[:backgroundImage] = data[:backgroundUrl]
      data[:logoImage] = data[:logoUrl]
      render(json: data.to_json)
    else
      site_banner = SiteBanner.new
      site_banner.update(
        publisher_id: current_publisher.id,
        channel_id: params[:channel_id],
        title: 'Brave Rewards',
        description:
'Thanks for stopping by. We joined Brave\'s vision of protecting your privacy because we believe that fans like you would support us in our effort to keep the web a clean and safe place to be.

Your tip is much appreciated and it encourages us to continue to improve our content.',
        donation_amounts: [1, 5, 10],
        default_donation: 5,
        social_links: {'youtube': '', 'twitter': '', 'twitch': ''}
      )
      data = site_banner.read_only_react_property
      data[:backgroundImage] = nil
      data[:logoImage] = nil
      render(json: data.to_json)
    end
  end

  def channels
    channels = []

    current_publisher.channels.each do |c|

    case c.details_type

      when "SiteChannelDetails"
        channel_details = SiteChannelDetails.find_by_id(c.details_id)
        channel_type = "website"
        channel_name = channel_details.url
      when "YoutubeChannelDetails"
        channel_details = YoutubeChannelDetails.find_by_id(c.details_id)
        channel_type = "youtube"
        channel_name = channel_details.name
      when "TwitterChannelDetails"
        channel_details = TwitterChannelDetails.find_by_id(c.details_id)
        channel_type = "twitter"
        channel_name = channel_details.name
      when "TwitchChannelDetails"
        channel_details = TwitchChannelDetails.find_by_id(c.details_id)
        channel_type = "twitch"
        channel_name = channel_details.name

    end

    channel = {
              'id' => c.id,
              'name' => channel_name,
              'type' => channel_type
              }

    channels.push(channel)

    end

    channel_mode = true
    channel_index = 0

    if(current_publisher.site_banners.where(default: true).exists?)
      channel_mode = false
      default_id = current_publisher.site_banners.where(default: true).first.channel_id
      channels.each_with_index do |chan, index|
        if(default_id == chan["id"])
          channel_index = index
        end
      end
    end
    data = {}
    data[:channels] = channels
    data[:channel_mode] = channel_mode
    data[:channel_index] = channel_index
    render(json: data.to_json)
  end

  def save
    site_banner = current_publisher.site_banners.where(channel_id: params[:channel_id]).first
    donation_amounts = JSON.parse(sanitize(params[:donation_amounts]))
    site_banner.update(
      default: params[:default],
      publisher_id: current_publisher.id,
      title: sanitize(params[:title]),
      donation_amounts: donation_amounts,
      default_donation: donation_amounts.second,
      social_links: params[:social_links].present? ? JSON.parse(sanitize(params[:social_links])) : {},
      description: sanitize(params[:description])
    )
    head :ok
  end

  def update_logo
    if params[:image].length > MAX_IMAGE_SIZE
      # (Albert Wang): We should consider supporting alerts. This might require a UI redesign
      # alert[:error] = "File size too big!"
      head :payload_too_large and return
    end
    site_banner = current_publisher.site_banners.where(channel_id: params[:channel_id]).first
    update_image(attachment: site_banner.logo, attachment_type: SiteBanner::LOGO)
    head :ok
  end

  def update_background_image
    if params[:image].length > MAX_IMAGE_SIZE
      # (Albert Wang): We should consider supporting alerts. This might require a UI redesign
      # alert[:error] = "File size too big!"
      head :payload_too_large and return
    end
    site_banner = current_publisher.site_banners.where(channel_id: params[:channel_id]).first
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
      logger.error "Outside padding range #{e.message}"
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

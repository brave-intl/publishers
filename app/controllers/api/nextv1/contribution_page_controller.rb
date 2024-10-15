class Api::Nextv1::ContributionPageController < Api::Nextv1::BaseController
  include PublishersHelper
  include ActiveStorage::SetCurrent

  MAX_IMAGE_SIZE = 10_000_000

  def index
    channel_list = current_publisher.channels.as_json(only: [:id, :details_type],
      include: {
        details: {only: [], methods: [:url, :publication_title]}
      })
    render(json: channel_list)
  end

  def show
    current_channel = current_publisher.channels.find(params[:id])

    SiteBanner.new_helper(current_publisher.id, current_channel.id) if !current_channel.site_banner

    channel_data = format_channel_data(current_channel.reload)
    render(json: channel_data)
  end

  def update
    begin
      current_channel = current_publisher.channels.find(params[:id])
      site_banner = current_channel.site_banner
    rescue ActiveRecord::RecordNotFound
      return render json: {}, status: 404
    end

    permitted_params = params.permit(
      :contribution_page,
      :id,
      :format,
      :description,
      :title,
      :logo,
      :cover,
      socialLinks: [:twitter, :reddit, :github, :vimeo, :youtube, :twitch]
    )

    logo_length = permitted_params[:logo]&.length || 0
    cover_length = permitted_params[:cover]&.length || 0

    if (cover_length > MAX_IMAGE_SIZE) || (logo_length > MAX_IMAGE_SIZE)
      render(json: {errors: t("banner.upload_too_big")}, status: 400)
    end

    begin
      # don't erase old data, particularly other social links stored in the existing json string
      new_data = site_banner.read_only_react_property.deep_merge(permitted_params.to_hash.transform_keys(&:to_sym))
      # the 'sanatize' method in the update helper doesn't handle ruby hashes well
      site_banner.update_helper(new_data[:title], new_data[:description], new_data[:socialLinks].to_json)

      if permitted_params[:logo]
        site_banner.logo.attach(
          image_properties(permitted_params[:logo])
        )
        site_banner.save!
      end

      if permitted_params[:cover]
        site_banner.background_image.attach(
          image_properties(permitted_params[:cover])
        )
        site_banner.save!
      end
      site_banner.reload
      channel_data = format_channel_data(current_channel)
      render(json: channel_data, status: 200)
    rescue => e
      LogException.perform(e, publisher: current_publisher)
      render(json: {errors: "channel banner could not be updated"}, status: 400)
    end
  end

  def destroy_attachment
    begin
      current_channel = current_publisher.channels.find(params[:id])
      site_banner = current_channel.site_banner
    rescue ActiveRecord::RecordNotFound
      return render json: {}, status: 404
    end

    permitted_params = params.permit(:logo, :cover)

    site_banner.logo.purge if permitted_params[:logo] && site_banner.logo.attached?
    site_banner.background_image.purge if permitted_params[:cover] && site_banner.background_image.attached?

    channel_data = format_channel_data(current_channel.reload)
    render(json: channel_data)
  end

  private

  def format_channel_data(channel)
    channel.as_json(only: [:details_type, :id, :public_identifier],
      include: {
        details: {only: [], methods: [:url, :publication_title]},
        site_banner: {only: [], methods: [:read_only_react_property]}
      })
  end

  def image_properties(data)
    if data.starts_with?("data:image/jpeg") || data.starts_with?("data:image/jpg")
      extension = ".jpg"
    elsif data.starts_with?("data:image/png")
      extension = ".png"
    elsif data.starts_with?("data:image/webp")
      extension = ".webp"
    else
      LogException.perform(StandardError.new("Unknown image format:" + data), params: {})
      return nil
    end
    filename = Time.now.to_s.tr!(" ", "_").tr!(":", "_") + current_publisher.id

    temp_file = Tempfile.new([filename, extension])
    File.binwrite(temp_file.path, Base64.decode64(data))

    original_image_path = temp_file.path
    temp_file.rewind
    new_filename = generate_filename(source_image_path: original_image_path)
    {
      io: File.open(original_image_path),
      filename: new_filename + extension + ".padded",
      # remove period from beginning of extension type
      content_type: "image/#{extension}"
    }
  end

  def generate_filename(source_image_path:)
    File.open(source_image_path, "r") do |f|
      Digest::SHA256.hexdigest f.read
    end
  end
end

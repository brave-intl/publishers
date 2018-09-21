module ImageConversionHelper
  def save_temporary_image(filename:, extension:)
    temp_file = Tempfile.new([filename, extension])
    File.open(temp_file.path, 'wb') do |f|
      f.write(Base64.decode64(params[:image].split(',')[1]))
    end
    temp_file.path
  end

  def resize_to_dimensions_and_convert_to_jpg(source_image_path:, attachment_type:, filename:)
    # Set dimensions
    mini_magick_image = MiniMagick::Image.open(source_image_path)
    if attachment_type == SiteBanner::LOGO
      mini_magick_image.resize(SiteBanner::LOGO_DIMENSIONS)
    elsif attachment_type == SiteBanner::BACKGROUND
      mini_magick_image.resize(SiteBanner::BACKGROUND_DIMENSIONS)
    else
      LogException.perform(StandardError.new("Unknown attachment type:" + attachment_type), params: {})
      return nil
    end

    # Use JPG as its the most efficient standard
    mini_magick_image.format "jpg"

    new_filename = filename + "_resized"
    temp_file = Tempfile.new([new_filename, ".jpg"])

    mini_magick_image.write(temp_file)

    File.delete(source_image_path)

    temp_file.path
  end

=begin
  Adding an empty comment adds an arbitrary number of bytes
  Add a character to a comment adds 5 bytes (4 for padding)
=end
  def add_padding_to_image(source_image_path:, attachment_type:)
    # Add initial conversion to get file size
    MiniMagick::Tool::Convert.new do |convert|
      convert << source_image_path
      convert.merge!(["-set", "comment", ""])
      convert << source_image_path
    end

    current_file_size = File.open(source_image_path, 'r').size

    if attachment_type == SiteBanner::LOGO
      max_size = SiteBanner::LOGO_UNIVERSAL_FILE_SIZE
    elsif attachment_type == SiteBanner::BACKGROUND
      max_size = SiteBanner::BACKGROUND_UNIVERSAL_FILE_SIZE
    else
      LogException.perform(StandardError.new("Unknown attachment_type:" + attachment_type), params: {})
    end

    calculated_offset = max_size - current_file_size - 5

    if calculated_offset < 0
      LogException.perform(StandardError.new("Exceeds expected attachment size for padding to occur"), params: {})
    end

    MiniMagick::Tool::Convert.new do |convert|
      convert << source_image_path
      convert.merge!(["-set", "comment", "A" * calculated_offset])
      convert << source_image_path
    end

    source_image_path
  end

  def generate_filename(source_image_path:)
    File.open(source_image_path, 'r') do |f|
      Digest::SHA256.hexdigest f.read
    end
  end
end

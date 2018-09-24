module ImageConversionHelper
  LOOP_MAX = 15
  def save_temporary_image(filename:, extension:)
    p "saving temp file"
    temp_file = Tempfile.new([filename, extension])
    File.open(temp_file.path, 'wb') do |f|
      f.write(Base64.decode64(params[:image].split(',')[1]))
    end
    temp_file.path
  end

  def resize_to_dimensions_and_convert_to_jpg(source_image_path:, attachment_type:, filename:)
    p "resizing"
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
    iteration = 0
    if attachment_type == SiteBanner::LOGO
      target_file_size = SiteBanner::LOGO_UNIVERSAL_FILE_SIZE
    elsif attachment_type == SiteBanner::BACKGROUND
      target_file_size = SiteBanner::BACKGROUND_UNIVERSAL_FILE_SIZE
    else
      LogException.perform(StandardError.new("Unknown attachment_type:" + attachment_type), params: {})
    end

    while iteration < LOOP_MAX
      current_file_size = File.open(source_image_path, 'r').size
      p "#{attachment_type} Original file size: #{current_file_size}"
      break if current_file_size == target_file_size
      MiniMagick::Tool::Mogrify.new do |convert|
        convert.merge!(["-set", "comment", "A"])
        convert.merge!(["-quality", 100])
        convert << source_image_path
      end

      calculated_offset = target_file_size - current_file_size
      p "#{attachment_type} Calculated offset: #{calculated_offset}"

      if calculated_offset < 0
        LogException.perform(StandardError.new("Exceeds expected attachment size for padding to occur"), params: {})
        break
      end

      MiniMagick::Tool::Mogrify.new do |convert|
        convert.merge!(["-set", "comment", "A" * (calculated_offset + 1)])
        convert.merge!(["-quality", 100])
        convert << source_image_path
      end
    end
    current_file_size = File.open(source_image_path, 'r').size

    if current_file_size != target_file_size
      p "#{attachment_type} Wrong file size"
      LogException.perform(StandardError.new("Exceeds expected attachment size for padding to occur"), params: {})
    end

    source_image_path
  end

  def generate_filename(source_image_path:)
    File.open(source_image_path, 'r') do |f|
      Digest::SHA256.hexdigest f.read
    end
  end
end

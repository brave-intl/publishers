module ImageConversionHelper
  IMAGE_QUALITY = 50

  def resize_to_dimensions_and_convert_to_jpg(source_image_path:, attachment_type:, filename:)
    # Set dimensions
    mini_magick_image = MiniMagick::Image.open(source_image_path)
    if attachment_type == SiteBanner::LOGO
      mini_magick_image.resize(SiteBanner::LOGO_DIMENSIONS.join("x"))
    elsif attachment_type == SiteBanner::BACKGROUND
      mini_magick_image.resize(SiteBanner::BACKGROUND_DIMENSIONS.join("x"))
    else
      LogException.perform(StandardError.new("Unknown attachment type:" + attachment_type), params: {})
      return nil
    end

    # Use JPG as its the most efficient standard
    mini_magick_image.format "jpg"

    new_filename = filename + "_resized"
    temp_file = Tempfile.new([new_filename, ".jpg"])

    mini_magick_image.write(temp_file)

    temp_file.path
  end

=begin
  Adding an empty comment adds an arbitrary number of bytes
  Add a character to a comment adds 5 bytes (4 for padding)
=end
  def add_padding_to_image(source_image_path:, attachment_type:, quality:)
    # Add initial conversion to get file size
    if attachment_type == SiteBanner::LOGO
      target_file_size = SiteBanner::LOGO_UNIVERSAL_FILE_SIZE
    elsif attachment_type == SiteBanner::BACKGROUND
      target_file_size = SiteBanner::BACKGROUND_UNIVERSAL_FILE_SIZE
    else
      LogException.perform(StandardError.new("Unknown attachment_type:" + attachment_type), params: {})
    end

    file_size_after_one_byte = calculate_image_size_after_pad_one_byte(source_image_path, quality)

    delta = target_file_size - file_size_after_one_byte

    if delta < 0
      raise OutsidePaddingRangeError, "Expect minimum to be #{file_size_after_one_byte}"
    end

    MiniMagick::Tool::Convert.new do |convert|
      convert << source_image_path
      convert.merge!(["-set", "comment", "a" * (delta + 1)])
      convert.merge!(["-quality", quality])
      convert << source_image_path
    end

    source_image_path
  end

  def generate_filename(source_image_path:)
    File.open(source_image_path, 'r') do |f|
      Digest::SHA256.hexdigest f.read
    end
  end

  private

  def calculate_image_size_after_pad_one_byte(source_image_path, quality)
    mini_magick_image = MiniMagick::Image.open(source_image_path)

    new_filename = "_resized"

    temp_file = Tempfile.new([new_filename, ".jpg"])

    mini_magick_image.write(temp_file)

    MiniMagick::Tool::Convert.new do |convert|
      convert << temp_file.path
      convert.merge!(["-set", "comment", "a"])
      convert.merge!(["-quality", quality])
      convert << temp_file.path
    end

    File.size(temp_file.path)
  end

  class OutsidePaddingRangeError < RuntimeError; end
end

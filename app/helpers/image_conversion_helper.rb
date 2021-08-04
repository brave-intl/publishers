require "wasmer"
module ImageConversionHelper
  IMAGE_QUALITY = 50

  def resize_to_dimensions_and_convert_to_jpg(source_image_path:, attachment_type:, filename:)
    file = File.binread(source_image_path)
    file_bytes = file.unpack("C*")

    target_file_size = nil
    dimensions = nil
    if attachment_type == SiteBanner::LOGO
      target_file_size = SiteBanner::LOGO_UNIVERSAL_FILE_SIZE
      dimensions = SiteBanner::LOGO_DIMENSIONS
    elsif attachment_type == SiteBanner::BACKGROUND
      dimensions = SiteBanner::BACKGROUND_DIMENSIONS
      target_file_size = SiteBanner::BACKGROUND_UNIVERSAL_FILE_SIZE
    end

    if !dimensions
      LogException.perform(StandardError.new("Unknown attachment type:" + attachment_type), params: {})
      return nil
    end

    actual_jpeg_to_save = retry_quality(file_bytes: file_bytes,
                                        width: dimensions[0],
                                        height: dimensions[1],
                                        size: target_file_size,
                                        quality: 50)

    new_filename = filename + "_resized"
    temp_file = Tempfile.new([new_filename, ".jpg"], binmode: true)
    temp_file.write(actual_jpeg_to_save)
    temp_file.path
  end

  def retry_quality(file_bytes:, width:, height:, size:, quality:)
    Wasm::Thumbnail::Rb.resize_and_pad(file_bytes: file_bytes,
                                       width: width,
                                       height: height,
                                       size: size,
                                       quality: quality)
  rescue RuntimeError
    raise t("banner.upload_too_big") if quality <= 15

    # Try with reduced quality, start with 50, go down by 5 each time
    retry_quality(file_bytes: file_bytes,
                  width: width,
                  height: height,
                  size: size,
                  quality: quality - 5)
  end

  def generate_filename(source_image_path:)
    File.open(source_image_path, 'r') do |f|
      Digest::SHA256.hexdigest f.read
    end
  end
end

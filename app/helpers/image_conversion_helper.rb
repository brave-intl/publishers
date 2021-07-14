module ImageConversionHelper
  IMAGE_QUALITY = 50

  def resize_to_dimensions_and_convert_to_jpg(source_image_path:, attachment_type:, filename:)
    file = File.binread(source_image_path)
    file_bytes = file.unpack("C*")

    dimensions = nil
    if attachment_type == SiteBanner::LOGO
      dimensions = SiteBanner::LOGO_DIMENSIONS
    elsif attachment_type == SiteBanner::BACKGROUND
      dimensions = SiteBanner::BACKGROUND_DIMENSIONS
    end

    if !dimensions
      LogException.perform(StandardError.new("Unknown attachment type:" + attachment_type), params: {})
      return nil
    end

    actual_jpeg_hex_to_save = resize_image_with_wasm(file_bytes: file_bytes, dimensions: dimensions)

    new_filename = filename + "_resized"
    temp_file = Tempfile.new([new_filename, ".jpg"], binmode: true)
    temp_file.write(actual_jpeg_hex_to_save)
    temp_file.path
  end

  def resize_image_with_wasm(file_bytes:, dimensions:, size: 250000)
    require "wasmer"
    store = Wasmer::Store.new
    # Let's compile the module to be able to execute it!
    module_ = Wasmer::Module.new store, IO.read("#{Rails.root}/wasm_thumbnail.wasm", mode: "rb")

    # Now the module is compiled, we can instantiate it.
    instance = Wasmer::Instance.new module_, nil

    # This tells us how much space we'll need to put our image in the WASM env
    image_length = file_bytes.length
    input_pointer = instance.exports.allocate.call(image_length)
    # Get a pointer on the allocated memory so we can write to it
    memory = instance.exports.memory.uint8_view input_pointer

    # Put the image to resize in the allocated space
    for nth in 0..image_length - 1
      memory[nth] = file_bytes[nth]
    end

    # Do the actual resize and pad
    # Note that this writes to a portion of memory the new JPEG file, but right pads the rest of the space
    # we gave it with 0.
    begin
      output_pointer = instance.exports.resize_and_pad.call(input_pointer, image_length, dimensions[0], dimensions[1], size)
    rescue RuntimeError
      raise "Error processing the image."
    end
    # Get a pointer to the result
    memory = instance.exports.memory.uint8_view output_pointer

    # Only take the buffer that we told the rust function we needed. The resize function
    # makes a smaller image than the buffer we said, and then pads out the rest so we have to
    # go hunting for the bytes which represent the JPEG image. In hex, JPEG images start with
    # FFD8 and FFD9, so we can convert to hex and find the bounds of the image, then write to file
    bytes = memory.to_a.take(size)

    # Deallocate #TODO
    # instance.exports.deallocate.call(input_pointer, image_length)
    # instance.exports.deallocate.call(output_pointer, bytes.length)

    # The bytes passed back to us are ASCII-encoded, i.e. 8bit bytes. Interpret them as so,
    # and THEN convert to hex to search for the image bytes
    hex = bytes.pack('C*').unpack('H*')[0]
    start_jpg = hex.index('ffd8')
    # +3 to get to the index after the 9 in ffd9, i.e. the end of the image
    end_jpg = hex.rindex('ffd9') + 3
    # Extract the image bytes in hex
    hex_jpeg = hex[start_jpg..end_jpg]
    # Now give us a binary string, converting from hex
    [hex_jpeg].pack('H*')
  end

  #   Adding an empty comment adds an arbitrary number of bytes
  #   Add a character to a comment adds 5 bytes (4 for padding)
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

require 'test_helper'
class ImageConversionHelperTest < ActionView::TestCase
  test "resizes png to jpg" do
    source_image_path = "./app/assets/images/bat-logo@3x.png"
    temp_file_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: source_image_path.to_s,
      attachment_type: SiteBanner::LOGO,
      filename: "bat-logo")

    mini_magick_image = MiniMagick::Image.open(temp_file_path)
    assert_operator SiteBanner::LOGO_DIMENSIONS.first, :>=, mini_magick_image.resolution.first
    assert_operator SiteBanner::LOGO_DIMENSIONS.second, :>=, mini_magick_image.resolution.second
    assert "jpg", File.extname(source_image_path)
  end

  test "resizes a jpg to jpg" do
    source_image_path = "./app/assets/images/brave-lion@3x.jpg"
    temp_file_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: source_image_path.to_s,
      attachment_type: SiteBanner::LOGO,
      filename: "bat-logo"
    )

    mini_magick_image = MiniMagick::Image.open(temp_file_path)
    assert_operator SiteBanner::LOGO_DIMENSIONS.first, :>=, mini_magick_image.resolution.first
    assert_operator SiteBanner::LOGO_DIMENSIONS.second, :>=, mini_magick_image.resolution.second
    assert "jpg", File.extname(source_image_path)
  end

  test "adds padding to a logo for the correct file size" do
    source_image_path = "./app/assets/images/brave-lion@3x.jpg"
    mini_magick_image = MiniMagick::Image.open(source_image_path)
    mini_magick_image.format "jpg"
    temp_file = Tempfile.new(["brave-lion-copy", ".jpg"])

    mini_magick_image.write(temp_file)

    temp_file_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: temp_file.path,
      attachment_type: SiteBanner::LOGO,
      filename: "bat-logo"
    )

    add_padding_to_image(
      source_image_path: temp_file_path,
      attachment_type: SiteBanner::LOGO
    )

    assert_equal SiteBanner::LOGO_UNIVERSAL_FILE_SIZE, File.open(temp_file_path, 'r').size
  end

  test "adds padding to a background image for the correct file size" do

  end

  test "generates a consistent filename for an image" do

  end
end

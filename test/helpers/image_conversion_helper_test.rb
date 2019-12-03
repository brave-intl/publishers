require 'test_helper'
class ImageConversionHelperTest < ActionView::TestCase
  test "resizes png to jpg" do
    source_image_path = "./app/assets/images/bat-logo@3x.png"
    temp_file_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: source_image_path.to_s,
      attachment_type: SiteBanner::LOGO,
      filename: "bat_logo")

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
      filename: "brave_lion_logo"
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
    temp_file = Tempfile.new(["brave_lion_copy", ".jpg"])

    mini_magick_image.write(temp_file)

    temp_file_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: temp_file.path,
      attachment_type: SiteBanner::LOGO,
      filename: "brave_lion_logo"
    )

    add_padding_to_image(
      source_image_path: temp_file_path,
      attachment_type: SiteBanner::LOGO,
      quality: ImageConversionHelper::IMAGE_QUALITY
    )

    assert_equal SiteBanner::LOGO_UNIVERSAL_FILE_SIZE, File.open(temp_file_path, 'r').size
  end

  test "adds padding to a background image for the correct file size" do
    source_image_path = "./app/assets/images/san_francisco.jpg"
    mini_magick_image = MiniMagick::Image.open(source_image_path)
    mini_magick_image.format "jpg"
    temp_file = Tempfile.new(["san_francisco_copy", ".jpg"])

    mini_magick_image.write(temp_file)

    temp_file_path = resize_to_dimensions_and_convert_to_jpg(
      source_image_path: temp_file.path,
      attachment_type: SiteBanner::BACKGROUND,
      filename: "bat-logo"
    )

    add_padding_to_image(
      source_image_path: temp_file_path,
      attachment_type: SiteBanner::BACKGROUND,
      quality: ImageConversionHelper::IMAGE_QUALITY
    )

    assert_equal SiteBanner::BACKGROUND_UNIVERSAL_FILE_SIZE, File.open(temp_file_path, 'r').size
  end

  test "raises exception when attempting to submit a pad an exceptionally large image" do
    source_image_path = "./app/assets/images/san_francisco.jpg"
    mini_magick_image = MiniMagick::Image.open(source_image_path)
    mini_magick_image.format "jpg"
    temp_file = Tempfile.new(["san_francisco_copy", ".jpg"])

    mini_magick_image.write(temp_file)

    assert_raise ImageConversionHelper::OutsidePaddingRangeError do
      add_padding_to_image(
        source_image_path: temp_file.path,
        attachment_type: SiteBanner::LOGO,
        quality: ImageConversionHelper::IMAGE_QUALITY
      )
    end
  end

  test "generates a consistent filename for an image" do
    assert_equal "8957c0ef46cdabe73f93ee92b9a43ccb7fa8c9c319212c1f01a67957cab3b6b9", generate_filename(source_image_path: "./app/assets/images/brave-lion@3x.jpg")
  end
end

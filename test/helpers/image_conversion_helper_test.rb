require "test_helper"
describe ImageConversionHelper do
  include ImageConversionHelper

  it "generates a consistent filename for an image" do
    assert_equal "8957c0ef46cdabe73f93ee92b9a43ccb7fa8c9c319212c1f01a67957cab3b6b9", generate_filename(source_image_path: "./app/assets/images/brave-lion@3x.jpg")
  end

  describe "with image to test" do
    before do
      source_image_path = "./app/assets/images/brave-lion@3x.jpg"
      temp_file = Tempfile.new(["brave_lion_copy", ".jpg"])

      IO.copy_stream(source_image_path, temp_file.path)

      @temp_file_path = resize_to_dimensions_and_convert_to_jpg(
        source_image_path: temp_file.path,
        attachment_type: SiteBanner::LOGO,
        filename: "brave_lion_logo"
      )
    end

    it "resizes png to jpg" do
      width, height = FastImage.size(@temp_file_path)
      assert_operator SiteBanner::LOGO_DIMENSIONS.first, :>=, width
      assert_operator SiteBanner::LOGO_DIMENSIONS.second, :>=, height
      assert "jpg", File.extname(@temp_file_path)
    end

    it "resizes a jpg to jpg" do
      width, height = FastImage.size(@temp_file_path)
      assert_operator SiteBanner::LOGO_DIMENSIONS.first, :>=, width
      assert_operator SiteBanner::LOGO_DIMENSIONS.second, :>=, height
      assert "jpg", File.extname(@temp_file_path)
    end

    it "adds padding to a logo for the correct file size" do
      assert_equal SiteBanner::LOGO_UNIVERSAL_FILE_SIZE, File.open(@temp_file_path, "r").size
    end
  end
end

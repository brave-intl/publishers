require "test_helper"

class CompressionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "a visitor has a browser that supports compression" do
    ['gzip,deflate'].each do |compression_method|
      get root_path, headers: { 'HTTP_ACCEPT_ENCODING' => compression_method }
      assert response.headers['Content-Encoding']
    end
  end

  test "a visitor's browser does not support compression" do
    get root_path
    refute response.headers['Content-Encoding']
  end
end

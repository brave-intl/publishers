require "test_helper"
require "shared/mailer_test_helper"

class Api::Public::ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "channels endpoint returns 200" do
    get api_public_channels_path
    assert_response 200
  end

  test "channels endpoint response is json" do
     get api_public_channels_path
     assert JSON.parse(response.body)
  end

  test "channels endpoint returns at least as many verified channels" do 
   get api_public_channels_path
   assert JSON.parse(response.body).count >= Channel.verified.count
  end
end

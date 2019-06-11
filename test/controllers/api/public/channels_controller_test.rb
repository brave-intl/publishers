require "test_helper"
require "shared/mailer_test_helper"

class Api::V1::Public::ChannelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    CacheBrowserChannelsJsonJob.perform_now
  end

  test "channels endpoint returns 200" do
    get api_v1_public_channels_path
    assert_response 200
    assert JSON.parse(response.body)
  end

  test "channels endpoint returns at least as many verified channels" do
    get api_v1_public_channels_path
    assert JSON.parse(response.body).count >= Channel.verified.count
  end

  test "totals endpoint works" do
    get api_v1_public_channels_totals_path
    assert JSON.parse(response.body)
    assert_response 200
  end
end

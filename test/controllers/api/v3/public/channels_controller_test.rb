# typed: false

require "test_helper"

class Api::V3::Public::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  test "/api/v3/public/channels/total_verified returns json count of verified channels" do
    get "/api/v3/public/channels/total_verified", headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"}

    assert_equal(200, response.status)
    assert_equal(56, JSON.parse(response.body))
  end
end

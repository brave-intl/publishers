# typed: false

require "test_helper"

class Api::V3::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  test "/api/v3/channels/allowed_countries returns json representation of publisher" do
    channel1 = channels(:verified)
    channel2 = channels(:verified_blocked_country)

    post "/api/v3/channels/allowed_countries", headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"}, params: {channel_ids: [channel1.details.channel_identifier, channel2.details.channel_identifier]}

    assert_equal(200, response.status)
    assert_equal(JSON.parse(response.body), {channel1.details.channel_identifier => true, channel2.details.channel_identifier => false})
  end
end

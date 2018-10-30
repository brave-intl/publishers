require "test_helper"

class Api::V1::Stats::ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/stats/channels returns list of all channel uuids" do

    get "/api/v1/stats/channels", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)
    assert result.is_a?(Array)
    assert_equal(Channel.count, result.length)

  end

  test "/api/v1/stats/channels/:channel_id returns json representation of channel" do

    channel = channels(:stats_test)

    get "/api/v1/stats/channels/" + channel.id, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

      result = JSON.parse(response.body)

      puts channel.inspect

      assert_equal(result["channel_id"], channel.id);
      assert_equal(result["channel_identifier"], "stats.test");
      assert_equal(result["channel_type"], "website");
      assert_equal(result["name"], "https://stats.test");
      assert_equal(result["stats"], "{}");
      assert_equal(result["url"], "https://stats.test");
      assert_equal(result["owner_id"], channel.publisher.owner_identifier);
      assert_equal(result["verified"], true);

  end

  test "/api/v1/stats/channels/:channel_id returns 404 if channel not found" do

    get "/api/v1/stats/channels/" + "invalid-channel-id", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

      result = JSON.parse(response.body)
      assert_equal(404, response.status);

  end

end

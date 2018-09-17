require "test_helper"
require "shared/mailer_test_helper"

class Api::V1::Stats::ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/stats/channels returns list of all channel uuids" do

    get "/api/v1/stats/channels", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    result = JSON.parse(response.body)

    assert result.is_a?(Array)
    assert_equal(Channel.count, result.length)

  end

  test "/api/v1/stats/channels/:uuid returns json representation of channel, or 404 if not found" do

    if(Channel.last != nil)
      get "/api/v1/stats/channels/" + Channel.last.id, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      result = JSON.parse(response.body)
        assert(result.key?("uuid"))
        assert(result.key?("channel_id"))
        assert(result.key?("channel_type"))
        assert(result.key?("name"))
        assert(result.key?("stats"))
        assert(result.key?("url"))
        assert(result.key?("owner_id"))
        assert(result.key?("created_at"))
        assert(result.key?("verified"))

    else get "/api/v1/stats/channels/invalid_uuid", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
      result = JSON.parse(response.body)
      assert_equal(404, Integer(result["errors"][0]["status"]))
    end
  end
end

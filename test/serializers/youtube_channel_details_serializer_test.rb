require "test_helper"

class YoutubeChannelDetailsSerializerTest < ActiveSupport::TestCase
  test "youtube channels are serialized as JSON and include owner and channel details rolled up" do
    channel = channels(:google_verified)

    result = YoutubeChannelDetailsSerializer.new(channel.details).to_json
    json_result = JSON.parse(result)

    assert_equal "youtube#channel:78032", json_result["id"]
    assert_equal "google_oauth2", json_result["method"]
    assert_equal true, json_result["show_verification_status"]
    assert_equal "Alice the Verified", json_result["name"]
    assert_equal "alice2@verified.org", json_result["email"]
    assert_equal "+14159001421", json_result["phone_normalized"]
    assert_equal "BAT", json_result["preferred_currency"]
  end
end

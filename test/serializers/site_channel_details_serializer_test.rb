require "test_helper"

class SiteChannelDetailsSerializerTest < ActiveSupport::TestCase
  test "site channels are serialized as JSON and include owner and channel details rolled up" do
    channel = channels(:verified)

    result = SiteChannelDetailsSerializer.new(channel.details).to_json
    json_result = JSON.parse(result)

    assert_equal "verified.org", json_result["id"]
    assert_equal "wordpress", json_result["method"]
    assert_equal true, json_result["show_verification_status"]
    assert_equal "Alice the Verified", json_result["name"]
    assert_equal "alice@verified.org", json_result["email"]
    assert_nil json_result["preferred_currency"]
  end
end

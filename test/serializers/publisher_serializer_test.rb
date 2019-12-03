require "test_helper"

class PublisherSerializerTest < ActiveSupport::TestCase
  test "owners are serialized as JSON and include owner and channel details rolled up" do
    owner = publishers(:small_media_group)

    result = PublisherSerializer.new(owner).to_json
    json_result = JSON.parse(result)

    assert json_result.has_key?("owner_identifier")
    assert json_result.has_key?("email")
    assert json_result.has_key?("name")
    assert json_result.has_key?("channel_identifiers")
    assert json_result.has_key?("default_currency")
    assert json_result.has_key?("show_verification_status")
    assert json_result["channel_identifiers"].is_a?(Array)

    assert json_result.has_key?("channel_identifiers")
  end
end

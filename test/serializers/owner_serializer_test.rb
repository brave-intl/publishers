require "test_helper"

class OwnerSerializerTest < ActiveSupport::TestCase
  test "owners are serialized as JSON" do
    owner = publishers(:verified)

    result = PublisherSerializer.new(owner).to_json
    json_result = JSON.parse(result)

    assert_equal owner.owner_identifier, json_result["owner_identifier"]
    assert_equal owner.name, json_result["name"]
    assert_equal owner.phone, json_result["phone"]
    assert_equal owner.phone_normalized, json_result["phone_normalized"]
  end

  test "includes channels and channel details" do
    owner = publishers(:verified)

    result = PublisherSerializer.new(owner).to_json(include: "channels,channels.details")
    json_result = JSON.parse(result)

    assert_equal owner.owner_identifier, json_result["owner_identifier"]
    assert json_result["channels"].is_a?(Array)
    assert_equal true, json_result["channels"][0]["verified"]
    assert_equal "site_channel_details", json_result["channels"][0]["details"]["type"]
    assert_equal "09fd99d4-be26-529d-bd2a-8c07269a3c89", json_result["channels"][0]["details"]["site_channel_details"]["id"]
  end
end

require "test_helper"

class Api::OwnersControllerTest < ActionDispatch::IntegrationTest
  test "can get all owners with verifier channel identifiers as json" do
    owner = publishers(:verified)

    get "/api/owners/"

    assert_equal 200, response.status

    assert_match /#{owner.owner_identifier}/, response.body
    assert_match /#{owner.channels.verified.first.details.channel_identifier}/, response.body

    response_json = JSON.parse(response.body)
    assert response_json[0].has_key?("owner_identifier")
    assert response_json[0].has_key?("email")
    assert response_json[0].has_key?("name")
    assert response_json[0].has_key?("phone")
    assert response_json[0].has_key?("phone_normalized")
    assert response_json[0].has_key?("channel_identifiers")
    assert response_json[0].has_key?("show_verification_status")
    assert response_json[0]["channel_identifiers"].is_a?(Array)
  end
end
require "test_helper"

class Api::OwnersControllerTest < ActionDispatch::IntegrationTest
  test "can get all owners with verifier channel identifiers as json" do
    owner = publishers(:verified)

    get "/api/owners/"

    assert_equal 200, response.status

    assert_match /#{owner.owner_identifier}/, response.body
    assert_match /#{owner.channels.verified.first.details.channel_identifier}/, response.body
  end
end
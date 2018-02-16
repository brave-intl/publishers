require "test_helper"

class Api::OwnersControllerTest < ActionDispatch::IntegrationTest
  test "can get owners with verifier channel identifiers as json" do
    owner = publishers(:verified)

    get "/api/owners"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)

    assert_match /#{owner.owner_identifier}/, response.body
    assert_match /#{owner.channels.verified.first.details.channel_identifier}/, response.body
  end

  test "can paginate owners and set page size" do
    owner = publishers(:verified)

    get "/api/owners/?per_page=10"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 10, response_json.length
  end

  test "can paginate owners and set page size and number" do
    owner = publishers(:verified)

    get "/api/owners/?per_page=5&page=3"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 5, response_json.length
  end
end
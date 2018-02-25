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
    get "/api/owners/?per_page=10"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 10, response_json.length
  end

  test "can paginate owners and set page size and number" do
    # Delete any records after the 9th
    Publisher.where(id: Publisher.order("created_at desc").offset(9).pluck(:id)).delete_all

    get "/api/owners/?per_page=5&page=2"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 4, response_json.length
  end

  test "POST api/owners fails to create owner without email" do
    post api_owners_url, params: { email: ''}

    assert_equal 422, response.status
  end

  test "POST api/owners creates owner successfully" do
    post api_owners_url, params: { email: 'test@example.com'}

    assert_equal 201, response.status
    response_json = JSON.parse(response.body)
    p response_json
    assert_equal response['email'], 'test@example.com'
  end
end

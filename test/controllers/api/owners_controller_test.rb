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

  test "can create owners from json" do
    new_owner = {
        "email": "new_user@spud.com",
        "name": "Alice the New",
        "phone": "+16031230987",
        "show_verification_status": true
    }

    post "/api/owners/", as: :json, params: { owner: new_owner }

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert response_json["show_verification_status"]
    assert_equal "+16031230987", response_json["phone_normalized"]
    assert_equal "Alice the New", response_json["name"]
    assert_equal "new_user@spud.com", response_json["email"]
  end

  test "created owner has created_via_api flag set" do
    new_owner = {
        "email": "new_user@spud.com",
        "name": "Alice the New",
        "phone": "+16031230987",
        "show_verification_status": true
    }

    post "/api/owners/", as: :json, params: { owner: new_owner }

    assert_equal 200, response.status
    owner = Publisher.order(created_at: :asc).last
    assert owner.created_via_api?
  end

  test "will normalize phone numbers" do
    new_owner = {
        "email": "new_user@spud.com",
        "name": "Alice the New",
        "phone": "6031230987",
        "show_verification_status": false
    }

    post "/api/owners/", as: :json, params: {owner: new_owner }

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)

    assert_equal "+16031230987", response_json["phone_normalized"]
    assert_nil response_json["show_verification_status"]
  end

  test "will return validation errors" do
    new_owner = {
        "email": "new_user@spud.com",
        "name": "Alice the New",
        "phone": "6031230987",
        "show_verification_status": false
    }

    post "/api/owners/", as: :json, params: {owner: new_owner }

    assert_equal 200, response.status

    new_owner["phone"] = "603thisisprivate"
    post "/api/owners/", as: :json, params: {owner: new_owner }
    assert_equal 422, response.status

    response_json = JSON.parse(response.body)

    assert_equal "Validation failed: Email has already been taken, Phone Number is an invalid number", response_json["message"]
  end
end

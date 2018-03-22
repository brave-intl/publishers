require "test_helper"

class Api::TokensControllerTest < ActionDispatch::IntegrationTest
  test "can get tokens with verifier channel identifiers as json" do
    details = site_channel_details(:global_inprocess_details)

    get "/api/tokens"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)

    assert_match /#{details.channel.publisher.owner_identifier}/, response.body
    assert_match /#{details.channel.id}/, response.body

    too_old_details = site_channel_details(:to_verify_details)
    refute_match /#{too_old_details.channel.publisher.owner_identifier}/, response.body
    refute_match /#{too_old_details.channel.id}/, response.body
  end

  test "can paginate tokens and set page size" do
    get "/api/tokens/?per_page=2"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 2, response_json.length
  end

  test "can set max_age in days" do
    get "/api/tokens/?max_age=141"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 10, response_json.length

    details = site_channel_details(:to_verify_details)
    assert_match /#{details.channel.publisher.owner_identifier}/, response.body
    assert_match /#{details.channel.id}/, response.body
  end

  test "can paginate tokens, set page size and number, and set max_age in days" do
    get "/api/tokens/?per_page=2&page=4&max_age=141"

    assert_equal 200, response.status

    response_json = JSON.parse(response.body)
    assert_equal 2, response_json.length
  end

  test "max_age must be an integer" do
    get "/api/tokens/?max_age=foo"

    assert_equal 400, response.status
    assert_match "Invalid arguement", response.body
  end

end
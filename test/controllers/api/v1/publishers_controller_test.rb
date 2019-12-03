require "test_helper"

class Api::V1::PublishersControllerTest < ActionDispatch::IntegrationTest
  test "/api/v1/publishers/:publisher_id returns json representation of publisher" do
    publisher = publishers(:suspended)
    get "/api/v1/publishers/" + publisher.id, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    payload = JSON.parse(response.body).deep_symbolize_keys
    assert_equal(publisher.id, payload[:id])
    assert_equal("suspended", payload[:current_status][:status])
  end

  test "/api/v1/publishers/:publisher_id/publisher_status_updates updates status of publisher" do
    publisher = publishers(:suspended)
    post "/api/v1/publishers/" + publisher.id + "/publisher_status_updates", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }, params: { status: "active", note: "yolo", admin: "hello@brave.com" }
    status = publisher.last_status_update.status
    assert_equal("active", status)
  end

  test "/api/v1/publishers/:publisher_id/publisher_status_updates will not update without note" do
    publisher = publishers(:suspended)
    post "/api/v1/publishers/" + publisher.id + "/publisher_status_updates", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }, params: { status: "active", note: nil, admin: "hello@brave.com" }
    assert_equal(404, response.status)
  end
end

# typed: ignore
# frozen_string_literal: true

require "test_helper"

class BitflyerRefresherTest < ActiveSupport::TestCase
  test "refresh success" do
    connection = bitflyer_connections(:enabled_bitflyer_connection)
    mock_auth = MiniTest::Mock.new.expect(:refresh, {
      "access_token" => "a",
      "refresh_token" => "b",
      "expires_in" => 100
    },
      [{token: connection.refresh_token}])
    refresher = Bitflyer::Refresher.new(impl_refresher: mock_auth)

    updated = refresher.call(bitflyer_connection: connection)
    assert_equal(updated.access_token, "a")
    assert_equal(updated.refresh_token, "b")
    assert_equal(updated.expires_in, "100")
    assert updated.access_expiration_time.present?
  end

  test "http impl refresh success" do
    token = "token"
    raw_response = {
      access_token: "eyJhbGciOi",
      refresh_token: "eyJhbGciO",
      expires_in: 2592000,
      scope: "create_deposit_id",
      account_hash: "4be",
      token_type: "Bearer"
    }
    mock_response = MiniTest::Mock.new.expect(:body, JSON.dump(raw_response))
    mock_http_client = MiniTest::Mock.new.expect(:post, mock_response, [
      Bitflyer::Http.oauth_path, {
        client_id: Bitflyer::Http.client_id,
        client_secret: Bitflyer::Http.client_secret,
        grant_type: Bitflyer::Refresher::REFRESH_TOKEN,
        scope: Bitflyer::Http.oauth_scope,
        refresh_token: token
      }
    ])

    result = Bitflyer::Refresher::RefresherHttpImpl.refresh(token: token, http_client: mock_http_client)
    assert_equal(result["refresh_token"], raw_response[:refresh_token])
  end
end

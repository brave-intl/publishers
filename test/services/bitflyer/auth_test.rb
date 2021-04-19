# frozen_string_literal: true

require "test_helper"

class BitflyerAuthTest < ActiveSupport::TestCase
  test 'refresh success' do
    token = 'token'
    raw_response = {
      "access_token": "eyJhbGciOi",
      "refresh_token": "eyJhbGciO",
      "expires_in": 2592000,
      "scope": "create_deposit_id",
      "account_hash": "4be",
      "token_type": "Bearer",
    }
    mock_response = MiniTest::Mock.new.expect(:body, JSON.dump(raw_response))
    mock_http_client = MiniTest::Mock.new.expect(:post, mock_response, [
      Bitflyer.oauth_path, {
        client_id: Bitflyer.client_id,
        client_secret: Bitflyer.client_secret,
        grant_type: Bitflyer::Auth::REFRESH_TOKEN,
        scope: Bitflyer.scope,
        refresh_token: token,
      },
    ])

    result = Bitflyer::Auth.refresh(token: token, http_client: mock_http_client)
    assert_equal(result.refresh_token, raw_response[:refresh_token])
  end
end

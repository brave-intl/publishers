# frozen_string_literal: true

require "test_helper"

class BitflyerRefresherTest < ActiveSupport::TestCase
  test 'refresh success' do
    connection = bitflyer_connections(:connection_with_token)
    mock_auth = MiniTest::Mock.new.expect(:refresh, OpenStruct.new({
      access_token: 'a',
      refresh_token: 'b',
      expires_in: 100,
    }),
                                          [{ token: connection.refresh_token }])
    refresher = Bitflyer::Refresher.new(impl_refresher: mock_auth)

    updated = refresher.call(bitflyer_connection: connection)
    assert_equal(updated.access_token, "a")
    assert_equal(updated.refresh_token, "b")
    assert_equal(updated.expires_in, "100")
    assert updated.access_expiration_time.present?
  end
end

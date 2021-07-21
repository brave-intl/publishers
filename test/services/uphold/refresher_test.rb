# frozen_string_literal: true

require "test_helper"

class UpholdRefresherTest < ActiveSupport::TestCase
  def received_from_uphold
    "{\"access_token\":\"3f2\",\"token_type\":\"bearer\",\"expires_in\":3599,\"refresh_token\":\"82b0\",\"scope\":\"cards:read user:read\"}"
  end

  test 'refresh no previous token' do
    connection = uphold_connections(:google_connection)
    assert_nil connection.refresh_token
    mock_auth = MiniTest::Mock.new.expect(:refresh, received_from_uphold,
                                          [connection])
    refresher = Uphold::Refresher.new(impl_refresher: mock_auth)

    updated = refresher.call(uphold_connection: connection)
    assert_equal(updated, nil)
    assert_nil connection.refresh_token
  end

  test 'refresh with previous token' do
    connection = uphold_connections(:basic_connection)
    refute_nil connection.refresh_token
    mock_auth = MiniTest::Mock.new.expect(:refresh, received_from_uphold,
                                          [connection])
    refresher = Uphold::Refresher.new(impl_refresher: mock_auth)
    refresher.call(uphold_connection: connection)
    refute_nil connection.refresh_token
    assert_equal(connection.reload.refresh_token, '82b0')
  end
end

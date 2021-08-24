# frozen_string_literal: true

require "test_helper"

class UpholdRefresherTest < ActiveSupport::TestCase
  def received_from_uphold
    "{\"access_token\":\"3f2\",\"token_type\":\"bearer\",\"expires_in\":3599,\"refresh_token\":\"82b0\",\"scope\":\"cards:read user:read\"}"
  end

  test 'refresh no previous token' do
    connection = uphold_connections(:completed_partner_connection)
    assert_nil connection.refresh_token
    mock_auth = MiniTest::Mock.new.expect(:refresh_authorization, received_from_uphold,
                                          [connection])
    refresher = Uphold::Refresher.new(impl_refresher: mock_auth)

    updated = refresher.call(uphold_connection: connection)
    assert_nil updated
    assert_nil connection.refresh_token
  end

  test 'do not refresh because token too new' do
    connection = uphold_connections(:google_connection)
    refute_nil connection.refresh_token
    refute_equal(connection.reload.refresh_token, '82b0')

    mock_auth = MiniTest::Mock.new.expect(:refresh_authorization, received_from_uphold,
                                          [connection])
    refresher = Uphold::Refresher.new(impl_refresher: mock_auth)
    refresher.call(uphold_connection: connection)
    refute_equal(connection.reload.refresh_token, '82b0')
  end

  test 'refresh with previously expired token' do
    connection = uphold_connections(:google_connection)
    refute_nil connection.refresh_token
    refute_equal(connection.reload.refresh_token, '82b0')

    mock_auth = MiniTest::Mock.new.expect(:refresh_authorization, received_from_uphold,
                                          [connection])
    refresher = Uphold::Refresher.new(impl_refresher: mock_auth)
    travel 2.days do
      refresher.call(uphold_connection: connection)
    end
    assert_equal(connection.reload.refresh_token, '82b0')
  end
end

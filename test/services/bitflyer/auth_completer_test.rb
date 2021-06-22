# frozen_string_literal: true

require "test_helper"

class BitflyerAuthCompleterTest < ActiveSupport::TestCase
  test 'it completes successfully' do
    connection = bitflyer_connections(:enabled_bitflyer_connection)
    mock_http = mock
    access_token = '123'
    refresh_token = '456'
    account_hash = '789'

    data = OpenStruct.new(
      body: JSON.dump(
        {
          access_token: access_token,
          refresh_token: refresh_token,
          account_hash: account_hash,
        }
      )
    )
    mock_http.expects(:post_form).returns(data)

    mock_deposit_job = mock
    mock_deposit_job.expects(:perform).at_least_once

    refute_equal(connection.access_token, access_token)
    refute_equal(connection.refresh_token, refresh_token)
    refute_equal(connection.display_name, account_hash)

    completer = Bitflyer::AuthCompleter.new(http_lib: mock_http,
                                            missing_deposit_job: mock_deposit_job)

    result = completer.call(publisher: connection.publisher, code: 'ABC')

    connection.reload

    assert_equal(result, true)
    assert_equal(connection.access_token, access_token)
    assert_equal(connection.refresh_token, refresh_token)
    assert_equal(connection.display_name, account_hash)
  end
end

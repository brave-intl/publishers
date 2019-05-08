require 'test_helper'

class CleanStaleUpholdDataJobTest < ActiveJob::TestCase
  test "cleans uphold codes sitting longer than timeout" do
    ActiveRecord::Base.record_timestamps = false

    publisher = publishers(:default)
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.save!

    publisher.uphold_connection.updated_at = UpholdConnection::UPHOLD_CODE_TIMEOUT.ago - 1.second
    publisher.save!

    ActiveRecord::Base.record_timestamps = true
    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_code successfully wiped
    assert_nil publisher.uphold_connection.uphold_code
  end

  test "cleans stalled access params sitting longer than timeout" do
    ActiveRecord::Base.record_timestamps = false
    publisher = publishers(:default)
    publisher.uphold_connection.uphold_access_parameters = "foo"
    publisher.save!

    publisher.uphold_connection.updated_at = UpholdConnection::UPHOLD_ACCESS_PARAMS_TIMEOUT.ago - 1.second
    publisher.save!

    ActiveRecord::Base.record_timestamps = true
    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_access_parameters successfully wiped
    assert_nil publisher.uphold_connection.uphold_access_parameters
  end

  test "does not clean uphold codes before timeout" do
    ActiveRecord::Base.record_timestamps = false

    publisher = publishers(:default)
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.uphold_connection.updated_at = Time.now
    publisher.uphold_connection.save!
    ActiveRecord::Base.record_timestamps = true
    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_code is not wiped
    assert_equal publisher.uphold_connection.uphold_code, "foo"
  end

  test "does not clean uphold access parameters before timeout" do
    ActiveRecord::Base.record_timestamps = false
    publisher = publishers(:default)
    publisher.uphold_connection.uphold_access_parameters = "foo"
    publisher.uphold_connection.updated_at = Time.now
    publisher.uphold_connection.save!

    ActiveRecord::Base.record_timestamps = true
    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_access_parameters not wiped
    assert_equal "foo", publisher.uphold_connection.uphold_access_parameters
  end
end

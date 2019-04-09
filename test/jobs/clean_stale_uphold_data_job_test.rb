require 'test_helper'

class CleanStaleUpholdDataJobTest < ActiveJob::TestCase
  test "cleans uphold codes sitting longer than timeout" do
    publisher = publishers(:default)
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.save!

    # override `before_validation :set_uphold_updated_at`
    publisher.uphold_updated_at = Publisher::UPHOLD_CODE_TIMEOUT.ago - 1.second
    publisher.save!

    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_code successfully wiped
    assert_nil publisher.uphold_connection.uphold_code
  end

  test "cleans stalled access params sitting longer than timeout" do
    publisher = publishers(:default)
    publisher.uphold_connection.uphold_access_parameters = "foo"
    publisher.save!

    # override `before_validation :set_uphold_updated_at`
    publisher.uphold_connection.uphold_updated_at = Publisher::UPHOLD_ACCESS_PARAMS_TIMEOUT.ago - 1.second
    publisher.save!

    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_access_parameters successfully wiped
    assert_nil publisher.uphold_access_parameters
  end

  test "does not clean uphold codes before timeout" do
    publisher = publishers(:default)
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.uphold_connection.uphold_updated_at = Time.now
    publisher.uphold_connection.save!

    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_code is not wiped
    assert_equal publisher.uphold_connection.uphold_code, "foo"
  end

  test "does not clean uphold access parameters before timeout" do
    publisher = publishers(:default)
    publisher.uphold_access_parameters = "foo"
    publisher.uphold_updated_at = Time.now
    publisher.save!

    CleanStaleUpholdDataJob.perform_now

    publisher.reload

    # verify publisher uphold_access_parameters not wiped
    assert_equal publisher.uphold_access_parameters, "foo"
  end
end

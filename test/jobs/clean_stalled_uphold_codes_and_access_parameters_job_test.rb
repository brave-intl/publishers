require 'test_helper'

class CleanStalledUpholdCodesAndAccessParametersJobTest < ActiveJob::TestCase
  test "cleans uphold codes more than five minutes old" do
    publisher = publishers(:default)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    publisher.uphold_updated_at = Time.now - 6.minutes
    publisher.save!

    CleanStalledUpholdCodesAndAccessParametersJob.perform_now

    publisher.reload

    # verify publisher uphold_code successfully wiped
    assert_nil publisher.uphold_code 
  end

  test "cleans stalled access params more than 2 hours old" do
    publisher = publishers(:default)
    publisher.uphold_access_parameters = "foo"
    publisher.uphold_updated_at = Time.now - 3.hours
    publisher.save!

    CleanStalledUpholdCodesAndAccessParametersJob.perform_now

    publisher.reload

    # verify publisher uphold_access_parameters successfully wiped
    assert_nil publisher.uphold_access_parameters
  end

  test "does not clean uphold codes less than five minutes old" do
    publisher = publishers(:default)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    publisher.uphold_updated_at = Time.now
    publisher.save!

    CleanStalledUpholdCodesAndAccessParametersJob.perform_now

    publisher.reload

    # verify publisher uphold_code is not wiped
    assert_equal publisher.uphold_code, "foo"
  end

  test "does not clean uphold access parameters less than 2 hours old" do
    publisher = publishers(:default)
    publisher.uphold_access_parameters = "foo"
    publisher.uphold_updated_at = Time.now - 1.hours
    publisher.save!

    CleanStalledUpholdCodesAndAccessParametersJob.perform_now

    publisher.reload

    # verify publisher uphold_access_parameters not wiped
    assert_equal publisher.uphold_access_parameters, "foo"
  end
end
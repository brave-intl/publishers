require "test_helper"
require "webmock/minitest"

class Cache::Metrics::UpholdKycByCountryJobTest < ActiveJob::TestCase
  test "creates two daily metrics and verifies based on country" do
    assert_equal 0, DailyMetric.count
    Cache::Metrics::UpholdKycByCountryJob.perform_now
    assert_not_equal 0, DailyMetric.count
    assert_nil DailyMetric.find_by(name: Cache::Metrics::UpholdKycByCountryJob::UPHOLD_CONNECTION_KYCD_BY_COUNTRY).result['usa']
    DailyMetric.destroy_all

    uphold_connections(:unconnected).update(is_member: true)
    Cache::Metrics::UpholdKycByCountryJob.perform_now

    assert_equal 1, DailyMetric.find_by(name: Cache::Metrics::UpholdKycByCountryJob::UPHOLD_CONNECTION_KYCD_BY_COUNTRY).result['usa']

    uphold_connections(:unconnected).update(is_member: false) # reset
  end
end

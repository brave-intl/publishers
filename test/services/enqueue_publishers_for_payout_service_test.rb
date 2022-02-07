# typed: false
require "test_helper"

class EnqueuePublishersForPayoutServiceTest < NoTransactDBBleanupTest
  self.use_transactional_tests = false

  test "can specify an existing payout report and a new one won't be created (strategy: :deletion)" do
    payout_report = payout_reports(:one)
    assert_no_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutService.new.call(final: false,
        payout_report_id: payout_report.id)
    end
  end
end

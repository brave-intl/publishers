# typed: false
require "test_helper"

class EnqueuePublishersForPayoutServiceTest < NoTransactDBBleanupTest
  self.use_transactional_tests = false

  test "validates type" do
    assert_raises(ArgumentError) {
      EnqueuePublishersForPayoutService.new.call(
        "string",
        final: false
      )
    }
  end

  test "percent completion is set" do
    payout_report = payout_reports(:one)
    assert payout_report.percent_complete == 0
    assert EnqueuePublishersForPayoutService.new.call(
      payout_report,
      final: false
    ).percent_complete == 1
  end

  test "status is set" do
    payout_report = payout_reports(:one)
    assert payout_report.percent_complete == 0
    assert EnqueuePublishersForPayoutService.new.call(
      payout_report,
      final: false
    ).status == "Complete"
  end

  test "status is set when enqueing fails" do
    PayoutReport.any_instance.stubs(:with_lock).raises(StandardError)
    payout_report = payout_reports(:one)

    assert EnqueuePublishersForPayoutService.new.call(
      payout_report,
      final: false
    ).status.start_with?("Error")
  end
end

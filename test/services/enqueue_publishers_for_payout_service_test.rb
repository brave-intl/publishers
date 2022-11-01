# typed: false

require "test_helper"

class EnqueuePublishersForPayoutServiceTest < NoTransactDBBleanupTest
  include MockRewardsResponses

  self.use_transactional_tests = false

  before do
    stub_rewards_parameters
  end

  test "validates type" do
    assert_raises(ArgumentError) {
      EnqueuePublishersForPayoutService.new.call(
        "string",
        final: false,
      )
    }
  end

  test "status is set" do
    payout_report = payout_reports(:one)
    report = EnqueuePublishersForPayoutService.new.call(
      payout_report,
      final: false
    )
    assert report.status == "Complete"
  end

  test "status is set when enqueing fails" do
    PayoutReport.any_instance.stubs(:with_lock).raises(StandardError)
    payout_report = payout_reports(:one)

    assert EnqueuePublishersForPayoutService.new.call(
      payout_report,
      final: false,
    ).status.start_with?("Error")
  end
end

require 'test_helper'

class EnqueuePublishersForPayoutJobTest < ActiveJob::TestCase
  test "launches a job per payout type" do
    prc = PayoutReport.count
    Payout::UpholdService.any_instance.expects(:perform).at_least_once.returns([])
    Payout::GeminiService.any_instance.expects(:perform).at_least_once.returns([])
    Payout::BitflyerService.any_instance.expects(:perform).at_least_once.returns([])
    EnqueuePublishersForPayoutJob.new.perform(
      final: false
    )
    assert_equal prc + 1, PayoutReport.count
  end

  test "can specify an existing payout report and a new one won't be created" do
    payout_report = payout_reports(:one)
    assert_no_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutJob.perform_now(final: false,
                                                payout_report_id: payout_report.id)
    end
  end
end

# typed: false

require "test_helper"

class EnqueuePublishersForPayoutJobTest < NoTransactDBBleanupTest
  include MockRewardsResponses

  self.use_transactional_tests = false

  before do
    stub_rewards_parameters
  end

  test "launches a job per payout type (strategy: :deletion)" do
    prc = PayoutReport.count
    Payout::UpholdService.any_instance.expects(:perform).at_least_once.returns([])
    Payout::GeminiService.any_instance.expects(:perform).at_least_once.returns([])
    Payout::BitflyerService.any_instance.expects(:perform).at_least_once.returns([])
    EnqueuePublishersForPayoutJob.new.perform(false)
    assert_equal prc + 1, PayoutReport.count
  end

  test "can specify an existing payout report and a new one won't be created (strategy: :deletion)" do
    payout_report = payout_reports(:one)
    assert_no_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutJob.perform_now(false, false, payout_report.id)
    end
  end
end

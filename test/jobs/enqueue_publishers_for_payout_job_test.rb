require 'test_helper'
require 'jobs/sidekiq_test_case'

class EnqueuePublishersForPayoutJobTest < SidekiqTestCase
  include ActiveJob::TestHelper
  include MockGeminiResponses

  before do
    mock_gemini_auth_request!
    mock_gemini_account_request!
    mock_gemini_recipient_id!
  end

  test "launches a job per payout type" do
    prc = PayoutReport.count
    EnqueuePublishersForPayoutJob.perform_now(
      should_send_notifications: false,
      final: false
    )
    assert_equal prc + 1, PayoutReport.count
    assert_equal Payout::UpholdJob.jobs.count, 1
    assert_equal Payout::GeminiJob.jobs.count, 1
    assert_equal Payout::BitflyerJob.jobs.count, 1
  end

  test "can specify an existing payout report and a new one won't be created" do
    payout_report = payout_reports(:one)
    assert_no_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutJob.perform_now(should_send_notifications: false,
                                                final: false,
                                                payout_report_id: payout_report.id)
    end
  end
end

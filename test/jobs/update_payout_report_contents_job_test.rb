require 'test_helper'

class UpdatePayoutReportContentsJobTest < ActiveJob::TestCase
  test "updates payout report contents for single report" do
    payout_report = payout_reports(:one)
    UpdatePayoutReportContentsJob.perform_now(payout_report_ids: payout_report.id)
    payout_report.reload
    assert_not_nil payout_report.contents
  end

  test "updates payout report contents for all reports" do
    payout_report = payout_reports(:one)
    UpdatePayoutReportContentsJob.perform_now
    payout_report.reload
    assert_not_nil payout_report.contents
  end
end

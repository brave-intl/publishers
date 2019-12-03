class UpdatePayoutReportContentsJob < ApplicationJob
  queue_as :scheduler

  def perform(payout_report_ids: [])
    if payout_report_ids.present?
      payout_reports = PayoutReport.where(id: payout_report_ids)
    else
      payout_reports = PayoutReport.all
    end

    payout_reports.each do |payout_report|
      payout_report.update_report_contents
    end
  end
end

module Payout
  class GeminiJob < ApplicationJob
    queue_as :scheduler

    def perform(should_send_notifications: false, payout_report_id: nil)
      publishers = Publisher.joins(:gemini_connection).with_verified_channel

      publishers.find_each do |publisher|
        IncludePublisherInPayoutReportJob.perform_async(
          payout_report_id: payout_report_id,
          publisher_id: publisher.id,
          should_send_notifications: should_send_notifications,
          kind: IncludePublisherInPayoutReportJob::GEMINI
        )
      end

      if payout_report_id.present?
        payout_report = PayoutReport.find(payout_report_id)
        payout_report.update(expected_num_payments: payout_report.expected_num_payments + PayoutReport.expected_num_payments(publishers))
      end
    end
  end
end

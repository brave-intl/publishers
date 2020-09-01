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
        number_of_payments = PayoutReport.expected_num_payments(publishers)
        payout_report.with_lock do
          payout_report.reload
          payout_report.expected_num_payments += number_of_payments
          payout_report.save!
        end
      end
    end
  end
end

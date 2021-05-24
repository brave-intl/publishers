# frozen_string_literal: true

module Payout
  class GeminiJobImplementation
    def self.build
      new(payout_report_job: IncludePublisherInPayoutReportJob)
    end

    def initialize(payout_report_job:)
      @payout_report_job = payout_report_job
    end

    def call(should_send_notifications: false, payout_report_id: nil, publisher_ids: [])
      if publisher_ids.present?
        publishers = Publisher.gemini_creators.where(id: publisher_ids)
      else
        publishers = Publisher.gemini_creators.with_verified_channel
      end

      publishers.find_each do |publisher|
        @payout_report_job.perform_async(
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

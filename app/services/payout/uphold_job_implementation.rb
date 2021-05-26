# frozen_string_literal: true

module Payout
  class UpholdJobImplementation
    def self.build
      new(payout_report_job: IncludePublisherInPayoutReportJob)
    end

    def initialize(payout_report_job:)
      @payout_report_job = payout_report_job
    end

    def call(should_send_notifications: false, manual: false, payout_report_id: nil, publisher_ids: [])
      if publisher_ids.present?
        publishers = Publisher.uphold_creators.where(id: publisher_ids)
      elsif manual
        publishers = Publisher.uphold_creators.invoice
      else
        publishers = Publisher.uphold_creators.with_verified_channel
      end

      if payout_report_id.present?
        payout_report = PayoutReport.find(payout_report_id)
        number_of_payments = PayoutReport.expected_num_payments(publishers)
        payout_report.with_lock do
          payout_report.reload
          payout_report.expected_num_payments = number_of_payments + payout_report.expected_num_payments
          payout_report.save!
        end
      end

      kind = IncludePublisherInPayoutReportJob::UPHOLD
      if manual && payout_report.present?
        kind = IncludePublisherInPayoutReportJob::MANUAL
      end

      publishers.find_each do |publisher|
        @payout_report_job.perform_async(
          payout_report_id: payout_report_id,
          publisher_id: publisher.id,
          kind: kind,
          should_send_notifications: should_send_notifications
        )
      end

      Rails.logger.info("Enqueued #{publishers.count} publishers for payment for uphold")
    end
  end
end

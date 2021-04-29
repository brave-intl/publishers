module Payout
  class BitflyerJob < ApplicationJob
    queue_as :scheduler

    def perform(should_send_notifications: false, payout_report_id: nil, publisher_ids: [])
      if publisher_ids.present?
        publishers = Publisher.where(selected_wallet_provider_type: [nil, 'BitflyerConnection']).
          joins(:bitflyer_connection).where(id: publisher_ids)
      else
        publishers = Publisher.where(selected_wallet_provider_type: [nil, 'BitflyerConnection']).
          joins(:bitflyer_connection).with_verified_channel
      end

      publishers.find_each do |publisher|
        IncludePublisherInPayoutReportJob.perform_async(
          payout_report_id: payout_report_id,
          publisher_id: publisher.id,
          kind: IncludePublisherInPayoutReportJob::BITFLYER
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

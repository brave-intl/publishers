class Payout::WireJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: false, payout_report_id:)
    payout_report = PayoutReport.find(payout_report_id)
    publishers = Publisher.wire_only.with_verified_channel
    publishers.find_each do |publisher|
      IncludePublisherInPayoutReportJob.perform_async(
        payout_report_id: payout_report.id,
        publisher_id: publisher.id
      )
    end

    payout_report.update(expected_num_payments: payout_report.expected_num_payments + PayoutReport.expected_num_payments(publishers))
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

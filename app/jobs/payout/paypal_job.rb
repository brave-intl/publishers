class Payout::PaypalJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: false, payout_report_id: nil)
    publishers = Publisher.joins(:paypal_connection).with_verified_channel.where(paypal_connections: { country: "JP" })
    publishers.find_each do |publisher|
      IncludePublisherInPayoutReportJob.perform_async(
        payout_report_id: payout_report_id,
        publisher_id: publisher.id,
        should_send_notifications: should_send_notifications,
        kind: IncludePublisherInPayoutReportJob::PAYPAL
      )
    end

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
      payout_report.update(expected_num_payments: payout_report.expected_num_payments + PayoutReport.expected_num_payments(publishers))
    end
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

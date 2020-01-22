class EnqueuePublishersForPaypalPayoutJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: false, final: true, manual: false, payout_report_id:)
    publishers = Publisher.joins(:paypal_connection).where(paypal_connections: { verified_account: true, country: "Japan" })
    publishers.find_each do |publisher|
      IncludePublisherInPayoutReportJob.perform_later(
        payout_report_id: payout_report.id,
        publisher_id: publisher.id,
        should_send_notifications: should_send_notifications,
        for_paypal: true
      )
    end
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

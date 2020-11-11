class Payout::PaypalJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: false, payout_report_id: nil, publisher_ids: [])
    if publisher_ids.present?
      publishers = Publisher.where(selected_wallet_provider_type: [nil, 'PaypalConnection'])
                            .joins(:paypal_connection)
                            .where(id: publisher_ids)
    else
      publishers = Publisher.where(selected_wallet_provider_type: [nil, 'PaypalConnection'])
                            .joins(:paypal_connection)
                            .with_verified_channel
                            .where(paypal_connections: { country: "JP" })
    end

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

      number_of_payments = PayoutReport.expected_num_payments(publishers)
      payout_report.with_lock do
        payout_report.reload
        payout_report.expected_num_payments += number_of_payments
        payout_report.save!
      end
    end
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

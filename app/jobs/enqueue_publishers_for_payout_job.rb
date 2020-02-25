# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  SEND_NOTIFICATIONS = "send_notifications".freeze

  def perform(should_send_notifications: false, final: true, manual: false, payout_report_id: "", publisher_ids: [], args: [])
    Rails.logger.info("Enqueuing publishers for payment.")

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    else
      payout_report = PayoutReport.create(final: final,
                                          manual: manual,
                                          fee_rate: fee_rate,
                                          expected_num_payments: 0)
    end

    should_send_notifications = SEND_NOTIFICATIONS.in? args
    Payout::UpholdJob.perform_later(
      manual: manual,
      should_send_notifications: should_send_notifications,
      payout_report_id: payout_report.id,
      publisher_ids: publisher_ids
    )
    Payout::PaypalJob.perform_later(
      should_send_notifications: should_send_notifications,
      payout_report_id: payout_report.id
    )
    Payout::WireJob.perform_later(
      payout_report_id: payout_report.id
    )

    payout_report
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

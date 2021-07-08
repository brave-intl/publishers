# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  SEND_NOTIFICATIONS = "send_notifications".freeze

  def perform(should_send_notifications: false, final: true, manual: false, payout_report_id: "", publisher_ids: [], args: [])
    return if should_send_notifications
    Rails.logger.info("Enqueuing publishers for payment.")

    should_send_notifications = SEND_NOTIFICATIONS.in? args
    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    elsif !should_send_notifications
      payout_report = PayoutReport.create(final: final,
                                          manual: manual,
                                          fee_rate: fee_rate,
                                          expected_num_payments: 0)
    end

    if should_send_notifications
      enqueue_emails_only(
        manual: manual,
        publisher_ids: publisher_ids
      )
    else
      enqueue_payout(
        manual: manual,
        payout_report: payout_report,
        publisher_ids: publisher_ids
      )
    end
    if payout_report.present?
      payout_report
    end
  end

  private

  def enqueue_emails_only(manual:, publisher_ids:)
    json_args = {
      should_send_notifications: true,
      manual: manual,
      publisher_ids: publisher_ids
    }.to_json
    Payout::UpholdJob.perform_async(json_args)
  end

  def enqueue_payout(payout_report:, manual:, publisher_ids:)
    # TODO: We unnecessarily spike Redis memory usage by repeating the amount of publisher_ids we enqueue.
    # Finds all the publishers that have these wallets connected and
    # kicks off IncludePublisherInPayoutReportJob for each one.
    json_args = {
      should_send_notifications: false,
      manual: manual,
      payout_report_id: payout_report.id,
      publisher_ids: publisher_ids
    }.to_json
    Payout::UpholdJob.perform_async(json_args)
    Payout::GeminiJob.perform_async(json_args)
    Payout::BitflyerJob.perform_async(json_args)
  end

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

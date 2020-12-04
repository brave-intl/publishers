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
      Eyeshade::CreateSnapshot.new.perform(payout_report_id: payout_report.id)
      payout_report
    end
  end

  private

  def enqueue_emails_only(manual:, publisher_ids:)
    Payout::UpholdJob.perform_later(
      manual: manual,
      should_send_notifications: true,
      publisher_ids: publisher_ids
    )
    Payout::PaypalJob.perform_later(
      should_send_notifications: true,
    )
  end

  def enqueue_payout(payout_report:, manual:, publisher_ids:)
    # Finds all the publishers that have these wallets connected and
    # kicks off IncludePublisherInPayoutReportJob for each one.
    Payout::UpholdJob.perform_later(
      manual: manual,
      payout_report_id: payout_report.id,
      publisher_ids: publisher_ids
    )
    Payout::GeminiJob.perform_later(
      payout_report_id: payout_report.id,
      publisher_ids: publisher_ids
    )
    Payout::PaypalJob.perform_later(
      payout_report_id: payout_report.id,
      publisher_ids: publisher_ids
    )
  end

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

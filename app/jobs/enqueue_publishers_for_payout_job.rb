# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  SEND_NOTIFICATIONS = "send_notifications".freeze

  def perform(should_send_notifications: false, final: true, manual: false, payout_report_id: "", publisher_ids: [], args: [])
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
    if publisher_ids.present?
      publishers = Publisher.where.not(selected_wallet_provider_id: nil, selected_wallet_provider_type: nil).where(id: publisher_ids).with_verified_channel
    else
      publishers = Publisher.where.not(selected_wallet_provider_id: nil, selected_wallet_provider_type: nil).with_verified_channel
    end

    publishers.find_each do |publisher|
      case publisher.selected_wallet_provider_type
      when "UpholdConnection"
        IncludePublisherInPayoutReportJob.perform_async(
          payout_report_id: payout_report_id,
          publisher_id: publisher.id,
          should_send_notifications: false,
          kind: IncludePublisherInPayoutReportJob::UPHOLD
        )
      when "GeminiConnection"
        IncludePublisherInPayoutReportJob.perform_async(
          payout_report_id: payout_report_id,
          publisher_id: publisher.id,
          should_send_notifications: false,
          kind: IncludePublisherInPayoutReportJob::GEMINI
        )
      when "PaypalConnection"
        if publishers.selected_wallet_provider.japanese_account?
          IncludePublisherInPayoutReportJob.perform_async(
            payout_report_id: payout_report_id,
            publisher_id: publisher.id,
            should_send_notifications: false,
            kind: IncludePublisherInPayoutReportJob::PAYPAL
          )
        end
      end
    end

    number_of_payments = PayoutReport.expected_num_payments(publishers)
    payout_report.with_lock do
      payout_report.reload
      payout_report.expected_num_payments += number_of_payments
      payout_report.save!
    end
  end

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

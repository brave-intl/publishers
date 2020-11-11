class Payout::UpholdJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: false, manual: false, payout_report_id: nil, publisher_ids: [])
    if publisher_ids.present?
      publishers = Publisher.where(selected_wallet_provider_type: [nil, 'UpholdConnection'])
                            .joins(:uphold_connection).where(id: publisher_ids)
    elsif manual
      publishers = Publisher.where(selected_wallet_provider_type: [nil, 'UpholdConnection'])
                            .joins(:uphold_connection).invoice
    else
      publishers = Publisher.where(selected_wallet_provider_type: [nil, 'UpholdConnection'])
                            .joins(:uphold_connection).with_verified_channel
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
      IncludePublisherInPayoutReportJob.perform_async(
        payout_report_id: payout_report_id,
        publisher_id: publisher.id,
        should_send_notifications: should_send_notifications,
        kind: kind
      )
    end

    Rails.logger.info("Enqueued #{publishers.count} publishers for payment for uphold")
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

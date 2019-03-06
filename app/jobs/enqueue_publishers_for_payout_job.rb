# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: false, final: true, payout_report_id: "", publisher_ids: [])
    Rails.logger.info("Enqueuing publishers for payment.")

    if publisher_ids.present?
      publishers = Publisher.where(id: publisher_ids)
    else
      publishers = Publisher.partner #Remember to put back channels
    end

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    else
      payout_report = PayoutReport.create(final: final,
                                          fee_rate: fee_rate,
                                          expected_num_payments: PayoutReport.expected_num_payments(publishers))
    end

    publishers.find_each do |publisher|
      puts publisher.email
      IncludePublisherInPayoutReportJob.perform_later(payout_report_id: payout_report.id,
                                                      publisher_id: publisher.id,
                                                      should_send_notifications: should_send_notifications)
    end
    Rails.logger.info("Enuqueued #{publishers.count} publishers for payment.")

    payout_report
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end

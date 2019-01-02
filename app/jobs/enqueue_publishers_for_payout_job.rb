# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  def perform(should_send_notifications: true, final: true, payout_report_id: "", publisher_ids: [])
    Rails.logger.info("Enqueuing publishers for payment.")

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    else
      payout_report = PayoutReport.create(final: final, fee_rate: fee_rate)
    end

    if publisher_ids.present?
      publishers = Publisher.where(id: publisher_ids)
    else
      publishers = Publisher.with_verified_channel.not_suspended
    end
    
    publishers.find_each do |publisher|
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

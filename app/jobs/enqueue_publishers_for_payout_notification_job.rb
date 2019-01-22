class EnqueuePublishersForPayoutNotificationJob < ApplicationJob
  queue_as :scheduler

  def perform(publisher_ids: [])
    Rails.logger.info("Enqueuing publishers for payment notifications.")

    if publisher_ids.present?
      publishers = Publisher.where(id: publisher_ids)
    else
      publishers = Publisher.with_verified_channel.not_suspended
    end
    
    publishers.find_each do |publisher|
      IncludePublisherInPayoutReportJob.perform_later(payout_report_id: nil,
                                                      publisher_id: publisher.id,
                                                      should_send_notifications: true)
    end
    Rails.logger.info("Enuqueued #{publishers.count} publishers for payment notifications.")
  end
end

# typed: ignore
class EnqueueEmailsForPromoPublishersJob < ApplicationJob
  queue_as :scheduler

  def perform
    Publisher.daily_emails_for_promo_stats.find_each do |publisher|
      Promo::EmailBreakdownsJob.perform_async(publisher.id)
    end
  end
end

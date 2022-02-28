# typed: ignore
class EnqueueEmailsForPromoPublishersJob < ApplicationJob
  queue_as :scheduler

  def perform(type)
    Publisher.daily_emails_for_promo_stats.find_each do |publisher|
      Promo::EmailBreakdownsJob.perform_async(publisher.id, type)
    end
  end
end

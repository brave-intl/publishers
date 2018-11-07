# Syncs promo enabled publishers referral statisitics every 10 minutes
class SyncPublisherPromoStatsJob < ApplicationJob
  include PromosHelper
  queue_as :transactional

  # Syncs promo stats for all publishers by default
  # If a publisher is provided, sync stats for only that publisher

  def perform(promo_id: active_promo_id, publisher_id: nil)
    if publisher_id
      PublisherPromoStatsFetcher.new(publisher: Publisher.find(publisher_id), promo_id: promo_id).perform
    else
      publishers = Publisher.where(promo_enabled_2018q1: true)
      publishers.find_each do |publisher|
        PublisherPromoStatsFetcher.new(publisher: publisher, promo_id: promo_id).perform
      end
    end
  end
end

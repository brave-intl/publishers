# Syncs promo enabled publishers referral statisitics every 10 minutes
class SyncPublisherPromoStatsJob < ApplicationJob
  include PromosHelper
  queue_as :transactional

  def perform(promo_id: active_promo_id)
    # Might be able to select fewer with a more specific query
    publishers = Publisher.where(promo_enabled_2018q1: true)

    publishers.find_each do |publisher|
      PublisherPromoStatsFetcher.new(publisher: publisher, promo_id: promo_id).perform
    end
  end
end

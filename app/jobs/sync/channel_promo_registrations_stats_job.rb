# typed: ignore

# Fetches and saves the referral stats for channel owned codes
class Sync::ChannelPromoRegistrationsStatsJob < ApplicationJob
  include PromosHelper

  def perform(wait = 1, limit = 1000, async = true)
    count = 0

    # Limit of 1000 with a batch size of 50 puts us at 20 requests total per run with a 1 second delay
    # between each batch of 50, making the total runtime around 1 minute or so. or ~ 20r/min or 1000 referrals/min
    #
    # If we run this on Every 2 minutes we can refresh all existing referrals every 24 hours continuously.
    #
    # It also allows me to test this without swamping the entire sidekiq queue
    PromoRegistration.from_referrer_program.where("promo_registrations.updated_at < ?", 24.hours.ago).select(:id).find_in_batches(batch_size: 50) do |batch|
      ids = batch.map(&:id)
      count += ids.length

      if async
        Sync::PromoRegistrationStatsJob.perform_async(ids)
      else
        Sync::PromoRegistrationStatsJob.new.perform(ids)
      end

      sleep(wait) if wait
    end

    count
  end
end

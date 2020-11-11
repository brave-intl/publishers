class SetPayoutInProgressJob < ApplicationJob
  queue_as :scheduler

  PAYOUT_IN_PROGRESS = 'payout_in_progress'.freeze

  def perform(set_to: true)
    Rails.cache.write(PAYOUT_IN_PROGRESS, set_to)
    Rails.logger.info("Set payout in progress to #{set_to}")
  end
end

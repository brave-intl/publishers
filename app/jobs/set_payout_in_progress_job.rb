class SetPayoutInProgressJob < ApplicationJob
  queue_as :scheduler

  def perform(set_to: true)
    Rails.cache.write('payout_in_progress', set_to)
    Rails.logger.info("Set payout in progress to #{set_to}")
    Rails.cache.write('payout_report_generating', set_to)
  end
end

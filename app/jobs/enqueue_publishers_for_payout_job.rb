# typed: ignore
# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  def perform(final: true, manual: false, payout_report_id: "", publisher_ids: [], args: [])
    ::EnqueuePublishersForPayoutService.new.call(final: final, manual: manual, payout_report_id: payout_report_id, publisher_ids: publisher_ids, args: args)
  end
end

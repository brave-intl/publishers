require 'retries_from_last_enqueued_publisher'

class Payout::UpholdJob
  include Sidekiq::Worker
  sidekiq_options queue: :scheduler
  include RetriesFromLastEnqueuedPublisher

  attr_reader :payout_report_job, :should_send_notifications, :payout_report_id, :publisher_ids
  attr_accessor :publishers

  def perform(json_args: {}.to_json)
    args = JSON.parse(json_args)
    @should_send_notifications = args["should_send_notifications"]
    @payout_report_id = args["payout_report_id"]
    @publisher_ids = args["publisher_ids"]
    @publishers = Publisher.valid_payable_uphold_creators
    @kind = args["manual"] && payout_report_id.present? ? IncludePublisherInPayoutReportJob::MANUAL : IncludePublisherInPayoutReportJob::UPHOLD

    enqueue_retryable_potential_payout!
  end
end

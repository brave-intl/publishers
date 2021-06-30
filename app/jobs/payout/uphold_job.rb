class Payout::UpholdJob
  include Sidekiq::Worker
  sidekiq_options queue: :scheduler

  def perform(json_args)
    args = JSON.parse(json_args)

    Payout::Service::RetriesFromLastEnqueuedPublisher.enqueue_retryable_potential_payout!(
      kind: args["manual"] && payout_report_id.present? ? IncludePublisherInPayoutReportJob::MANUAL : IncludePublisherInPayoutReportJob::UPHOLD,
      klass_name: self.class.name,
      payout_report_id: args["payout_report_id"],
      publisher_ids: args["publisher_ids"],
      publishers: Publisher.valid_payable_uphold_creators,
      should_send_notifications: args["should_send_notifications"],
    )
  end
end

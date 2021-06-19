module RetriesFromLastEnqueuedPublisher
  extend ActiveSupport::Concern

  def enqueue_retryable_potential_payout!
    # self.class.name is the name of the caller function
    last_enqueued_publisher_key = "#{self.class.name}-#{@payout_report_id || ""}"
    last_enqueued_publisher_id = Rails.cache.fetch(last_enqueued_publisher_key)

    if @publisher_ids.present?
      @publishers = @publishers.where(id: @publisher_ids)
    elsif @kind == IncludePublisherInPayoutReportJob::MANUAL
      @publishers = @publishers.invoice
    else
      @publishers = @publishers.with_verified_channel
    end

    @publishers = @publishers.where("publishers.id > ?", last_enqueued_publisher_id) if last_enqueued_publisher_id.present?
    @publishers = @publishers.order("publishers.id ASC")

    if @payout_report_id.present?
      payout_report = PayoutReport.find(@payout_report_id)
      if last_enqueued_publisher_id.nil? # don't retry after 1st write
        number_of_payments = PayoutReport.expected_num_payments(@publishers)
        payout_report.with_lock do
          payout_report.reload
          payout_report.expected_num_payments = number_of_payments + payout_report.expected_num_payments
          payout_report.save!
        end
      end
    end

    @publishers.pluck(:id).each do |publisher_id|
      IncludePublisherInPayoutReportJob.perform_async(
        payout_report_id: @payout_report_id,
        publisher_id: publisher_id,
        kind: @kind,
        should_send_notifications: @should_send_notifications
      )
      Rails.cache.write(last_enqueued_publisher_key, publisher_id.to_s, expires_in: 72.hours)
    end
  end
end

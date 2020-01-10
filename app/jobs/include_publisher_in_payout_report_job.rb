class IncludePublisherInPayoutReportJob
  include Sidekiq::Worker
  sidekiq_options queue: 'scheduler'

  def perform(arguments = {})
    # If payout_report_id is not present, we only want to send notifications
    # not create payments
    payout_report_id = arguments["payout_report_id"]
    publisher_id = arguments["publisher_id"]
    should_send_notifications = arguments["should_send_notifications"]

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    else
      payout_report = nil
    end

    publisher = Publisher.find(publisher_id)
    if for_paypal
      Paypal::PayoutReportPublisherIncluder.new(
        publisher:                 publisher,
        payout_report:             payout_report,
        should_send_notifications: should_send_notifications
      ).perform
    else
      PayoutReportPublisherIncluder.new(
        publisher:                 publisher,
        payout_report:             payout_report,
        should_send_notifications: should_send_notifications
      ).perform
    end
  end
end

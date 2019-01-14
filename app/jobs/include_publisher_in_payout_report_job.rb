class IncludePublisherInPayoutReportJob < ApplicationJob
  queue_as :scheduler
  
  def perform(payout_report_id:, publisher_id:, should_send_notifications:)

    # If payout_report_id is not present, we only want to send notifications
    # not create payments
    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id) 
    else
      payout_report = nil
    end

    publisher = Publisher.find(publisher_id)
    PayoutReportPublisherIncluder.new(publisher: publisher,
                                      payout_report: payout_report,
                                      should_send_notifications: should_send_notifications).perform
  end
end

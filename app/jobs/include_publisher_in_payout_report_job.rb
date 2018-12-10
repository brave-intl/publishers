class IncludePublisherInPayoutReportJob < ApplicationJob
  queue_as :scheduler
  
  def perform(payout_report_id:, publisher_id:, should_send_notifications:)
    payout_report = PayoutReport.find(payout_report_id)
    publisher = Publisher.find(publisher_id)
    PayoutReportPublisherIncluder.new(publisher: publisher,
                                      payout_report: payout_report,
                                      should_send_notifications: should_send_notifications).perform
  end
end
require 'test_helper'

class EnqueuePublishersForPayoutJobTest < ActiveJob::TestCase
  before do
    IncludePublisherInPayoutReportJob.clear
  end

  test "launches 1 job per publisher" do
    assert_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutJob.perform_now(
        should_send_notifications: false,
        final: false
      )
      perform_enqueued_jobs
      assert_equal(Publisher.joins(:uphold_connection).with_verified_channel.count + 
                   Publisher.joins(:paypal_connection).where(paypal_connections: { verified_account: true, country: "Japan" }).count, 
                   IncludePublisherInPayoutReportJob.jobs.size
                  )
    end
  end

  test "can specify an existing payout report and a new one won't be created" do
    payout_report = payout_reports(:one)
    assert_no_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutJob.perform_now(should_send_notifications: false,
                                                final: false,
                                                payout_report_id: payout_report.id)
    end
  end

  test "can supply a list of publisher ids" do
    publishers = Publisher.where.not(email: "priscilla@potentiallypaid.org").joins(:uphold_connection) + Publisher.joins(:paypal_connection).where(paypal_connections: { verified_account: true, country: "Japan" })

    EnqueuePublishersForPayoutJob.perform_now(
      should_send_notifications: false,
      final: false,
      publisher_ids: publishers.pluck(:id)
    )
    perform_enqueued_jobs
    assert_equal publishers.count, IncludePublisherInPayoutReportJob.jobs.size
  end
end

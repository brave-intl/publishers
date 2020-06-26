require 'test_helper'

class EnqueuePublishersForPayoutJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper
  before do
    IncludePublisherInPayoutReportJob.clear
  end

  test "launches a job per payout type" do
    prc = PayoutReport.count
    EnqueuePublishersForPayoutJob.perform_now(
      should_send_notifications: false,
      final: false
    )
    assert_equal prc + 1, PayoutReport.count
    assert_enqueued_jobs 2
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
    publishers = Publisher.where.not(email: "priscilla@potentiallypaid.org").joins(:uphold_connection) + Publisher.joins(:paypal_connection).with_verified_channel.where(paypal_connections: { country: "JP" })

    assert_enqueued_with(job: Payout::UpholdJob) do
      EnqueuePublishersForPayoutJob.perform_now(
        should_send_notifications: false,
        final: false,
        publisher_ids: publishers.pluck(:id)
      )
    end
    assert_enqueued_jobs 2
  end
end

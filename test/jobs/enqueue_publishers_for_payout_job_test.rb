require 'test_helper'

class EnqueuePublishersForPayoutJobTest < ActiveJob::TestCase
  test "launches 1 job per publisher" do
    assert_difference -> { PayoutReport.count } do
      assert_enqueued_jobs(Publisher.with_verified_channel.count) do
        EnqueuePublishersForPayoutJob.perform_now(should_send_notifications: false,
                                                  final: false)
      end
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
    publishers = Publisher.where.not(email: "priscilla@potentiallypaid.org")

    assert_enqueued_jobs(publishers.count) do
      EnqueuePublishersForPayoutJob.perform_now(should_send_notifications: false,
                                                final: false,
                                                publisher_ids: publishers.pluck(:id))
    end
  end
end

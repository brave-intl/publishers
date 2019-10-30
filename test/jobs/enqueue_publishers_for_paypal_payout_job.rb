require 'test_helper'

class EnqueuePublishersForPaypalPayoutJobTest < ActiveJob::TestCase
  test "launches 1 job per publisher" do
    assert_difference -> { PayoutReport.count } do
      assert_enqueued_jobs(Publisher.joins(:paypal_connections).with_verified_channel.count) do
        EnqueuePublishersForPaypalPayoutJob.perform_now(
          should_send_notifications: false,
          final: false
        )
      end
    end
  end
end

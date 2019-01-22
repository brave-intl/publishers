require 'test_helper'

class EnqueuePublishersForPayoutNotificationJobTest < ActiveJob::TestCase
  test "launches 1 job per publisher" do
    assert_difference -> { PayoutReport.count } do
      assert_enqueued_jobs(Publisher.with_verified_channel.not_suspended.count) do
        EnqueuePublishersForPayoutJob.perform_now()
      end
    end
  end
  
  test "can supply a list of publisher ids" do
    publishers = Publisher.where.not(email: "priscilla@potentiallypaid.org")

    assert_enqueued_jobs(publishers.count) do
      EnqueuePublishersForPayoutJob.perform_now(publisher_ids: publishers.pluck(:id))
    end
  end
end

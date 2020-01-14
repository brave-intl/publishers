require 'test_helper'

class EnqueuePublishersForPayoutNotificationJobTest < ActiveJob::TestCase
  before do
    IncludePublisherInPayoutReportJob.clear
  end

  test "launches 1 job per publisher" do
    assert_difference -> { PayoutReport.count } do
      EnqueuePublishersForPayoutJob.perform_now
      assert_equal Publisher.joins(:uphold_connection).with_verified_channel.count, IncludePublisherInPayoutReportJob.jobs.size
    end
  end

  test "can supply a list of publisher ids" do
    publishers = Publisher.where.not(email: "priscilla@potentiallypaid.org")

    EnqueuePublishersForPayoutJob.perform_now(publisher_ids: publishers.pluck(:id))
    assert_equal publishers.joins(:uphold_connection).count, IncludePublisherInPayoutReportJob.jobs.size
  end
end

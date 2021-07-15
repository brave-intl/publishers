require 'test_helper'
require 'jobs/sidekiq_test_case'

class EnqueueTopReferrerPayoutJobTest < SidekiqTestCase
  test 'it enqueues only top referrers to to call EnqueuePublishersForPayoutJob' do
    Payout::EnqueueTopReferrerPayoutJob.new.perform
    assert_equal 1, Payout::UpholdJob.jobs.count
    top_publisher_ids = Publisher.with_verified_channel.in_top_referrer_program.pluck(:id)
    job = Payout::UpholdJob.jobs.first
    assert_equal JSON.parse(job["args"].first)["publisher_ids"], top_publisher_ids

    Payout::UpholdJob.new.perform(job["args"].first)

    assert IncludePublisherInPayoutReportJob.jobs.count >= 1
    top_publisher_ids = Publisher.with_verified_channel.in_top_referrer_program.pluck(:id)
    IncludePublisherInPayoutReportJob.jobs.each do |job|
      assert job["args"].first["publisher_id"].in?(top_publisher_ids)
    end
  end

  test 'it creates PotentialPayments for top referrers as part of IncludePublisherInPayoutReportJob' do
    args = {
      kind: IncludePublisherInPayoutReportJob::UPHOLD,
      payout_report_id: payout_reports(:one).id,
      publisher_id: publishers(:top_referrer).id,
      should_send_notifications: false
    }
    assert_changes -> { PotentialPayment.count } do
      IncludePublisherInPayoutReportJob.new.perform(args)
    end
  end
end

# frozen_string_literal: true

require 'test_helper'
require 'jobs/sidekiq_test_case'

class UpholdJobTest < SidekiqTestCase
  test "it doesn't include Japanese payouts" do
    uphold_in_japan = publishers(:uphold_in_japan)
    assert uphold_in_japan.selected_wallet_provider.japanese_account?
    uphold_job = Payout::UpholdJob.new
    uphold_job.perform({}.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == uphold_in_japan.id }.count, 0
  end

  test "it doesn't include Japanese payouts when providing ids" do
    uphold_in_japan = publishers(:uphold_in_japan)
    uphold_job = Payout::UpholdJob.new
    uphold_job.perform({ publisher_ids: [uphold_in_japan.id] }.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == uphold_in_japan.id }.count, 0
  end

  test "for order and key presence" do
    uphold_job = Payout::UpholdJob.new
    uphold_job.perform({ payout_report_id: payout_reports(:one).id }.to_json)
    visited_publisher_id = nil
    assert IncludePublisherInPayoutReportJob.jobs.count > 0
    IncludePublisherInPayoutReportJob.jobs.each do |job|
      job_publisher_id = job["args"].first["publisher_id"]
      assert visited_publisher_id <= job_publisher_id if visited_publisher_id.present?
      visited_publisher_id = job_publisher_id
    end
    assert_equal visited_publisher_id, Rails.cache.fetch("Payout::UpholdJob-#{payout_reports(:one).id}")
  end
end

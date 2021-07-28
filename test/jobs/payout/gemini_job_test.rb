# frozen_string_literal: true

require 'test_helper'

class GeminiJobTest < ActiveSupport::TestCase
  before do
    Sidekiq::Worker.clear_all
  end
  test "it doesn't include Japanese payouts" do
    gemini_in_japan = publishers(:gemini_in_japan)
    assert gemini_in_japan.selected_wallet_provider.japanese_account?
    gemini_job = Payout::GeminiJob.new
    gemini_job.perform({}.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == gemini_in_japan.id }.count, 0
  end

  test "it doesn't include Japanese payouts when providing ids" do
    gemini_in_japan = publishers(:gemini_in_japan)
    gemini_job = Payout::GeminiJob.new
    gemini_job.perform({ publisher_ids: [gemini_in_japan.id] }.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == gemini_in_japan.id }.count, 0
  end

  test "for order and key presence" do
    Sidekiq::Worker.clear_all
    gemini_job = Payout::GeminiJob.new
    gemini_job.perform({ payout_report_id: payout_reports(:one).id }.to_json)
    visited_publisher_id = nil
    assert IncludePublisherInPayoutReportJob.jobs.count > 0
    IncludePublisherInPayoutReportJob.jobs.each do |job|
      job_publisher_id = job["args"].first["publisher_id"]
      assert visited_publisher_id <= job_publisher_id if visited_publisher_id.present?
      visited_publisher_id = job_publisher_id
    end
    assert_equal visited_publisher_id, Rails.cache.fetch("Payout::GeminiJob-#{payout_reports(:one).id}")
  end
end

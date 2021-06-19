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
    gemini_job.perform
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == gemini_in_japan.id }.count, 0
  end

  test "it doesn't include Japanese payouts when providing ids" do
    gemini_in_japan = publishers(:gemini_in_japan)
    gemini_job = Payout::GeminiJob.new
    gemini_job.perform(json_args: { publisher_ids: [gemini_in_japan.id] }.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == gemini_in_japan.id }.count, 0
  end
end

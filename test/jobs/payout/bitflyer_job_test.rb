# frozen_string_literal: true

require 'test_helper'

class BitflyerJobTest < ActiveSupport::TestCase
  test "it only includes Bitflyer-selected publishers with verified channels" do
    bitflyer_publisher = publishers(:bitflyer_enabled)
    bitflyer_job = Payout::BitflyerJob.new
    bitflyer_job.perform({payout_report_id: payout_reports(:one).id }.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == bitflyer_publisher.id }.count > 0
  end

  test "it includes ids you supply despite verified status" do
    bitflyer_publisher = publishers(:bitflyer_enabled)
    bitflyer_publisher.channels.destroy_all
    refute bitflyer_publisher.has_verified_channel?
    bitflyer_job = Payout::BitflyerJob.new
    bitflyer_job.perform({ publisher_ids: [bitflyer_publisher.id] }.to_json)
    assert IncludePublisherInPayoutReportJob.jobs.select { |job| job["args"].first["publisher_id"] == bitflyer_publisher.id }.count > 0
  end
end

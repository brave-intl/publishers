# frozen_string_literal: true

require 'test_helper'

class BitflyerJobImplementationTest < ActiveSupport::TestCase
  test "it only includes verified channels" do
    bitflyer_publisher = publishers(:bitflyer_enabled)
    mock_report_job = mock
    mock_report_job.expects(:perform_async).with { |*args|
      publisher = Publisher.find(args[0][:publisher_id])
      assert publisher.bitflyer_connection
      assert publisher.has_verified_channel?
    }.at_least_once
    bitflyer_job = Payout::BitflyerJobImplementation.new(payout_report_job: mock_report_job)
    bitflyer_job.call
  end

  test "it includes ids you supply despite verified status" do
    bitflyer_publisher = publishers(:bitflyer_suspended)
    bitflyer_publisher.channels.destroy_all
    refute bitflyer_publisher.has_verified_channel?
    mock_report_job = mock
    mock_report_job.expects(:perform_async).with { |*args|
      assert Publisher.find(args[0][:publisher_id]).bitflyer_connection
    }
    bitflyer_job = Payout::BitflyerJobImplementation.new(payout_report_job: mock_report_job)
    bitflyer_job.call(publisher_ids: [bitflyer_publisher.id])
  end
end

# frozen_string_literal: true

require 'test_helper'

class UpholdJobImplementationTest < ActiveSupport::TestCase
  test "it doesn't include Japanese payouts" do
    uphold_in_japan = publishers(:uphold_in_japan)
    assert uphold_in_japan.selected_wallet_provider.japanese_account?
    mock_report_job = mock
    mock_report_job.expects(:perform_async).with { |*args| 
      refute Publisher.find(args[0][:publisher_id]).uphold_connection.japanese_account? 
    }
    uphold_job = Payout::UpholdJobImplementation.new(payout_report_job: mock_report_job)
    uphold_job.call
  end

  test "it doesn't include Japanese payouts when providing ids" do
    uphold_in_japan = publishers(:uphold_in_japan)
    mock_report_job = mock
    mock_report_job.expects(:perform_async).never
    uphold_job = Payout::UpholdJobImplementation.new(payout_report_job: mock_report_job)
    uphold_job.call(publisher_ids: [uphold_in_japan.id])
  end
end

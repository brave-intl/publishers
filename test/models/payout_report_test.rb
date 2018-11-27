require "test_helper"

class PayoutReportTest < ActiveSupport::TestCase
  test "#total_amount returns the total amount ever paid" do
    assert_equal PayoutReport.total_amount.to_s, "270000000000"
  end

  test "#total_fees returns the total amount ever paid " do
    assert_equal PayoutReport.total_fees.to_s, "13500000000"
  end
  
  test "#total_payments returns the total amount ever paid " do
    assert_equal PayoutReport.total_payments, PotentialPayment.count
  end

  test "update_report_contents updates the report json" do
    payout_report = payout_reports(:one)
    assert_nil payout_report.contents
    payout_report.update_report_contents
    assert payout_report.contents.present?
  end
end

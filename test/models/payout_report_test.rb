require "test_helper"

class PayoutReportTest < ActiveSupport::TestCase
  test "#total_amount returns the total amount ever paid " do
    payout_reports  = []
    4.times do
      payout_reports.push(PayoutReport.create(amount: "10000000000000000000"))
    end

    assert_equal PayoutReport.total_amount.to_s, "40.0"
  end


  test "#total_fees returns the total amount ever paid " do
    payout_reports  = []
    4.times do
      payout_reports.push(PayoutReport.create(fees: "10000000000000000000"))
    end
    
    assert_equal PayoutReport.total_fees.to_s, "40.0"
  end
  
  test "#total_payments returns the total amount ever paid " do
    payout_reports  = []
    4.times do
      payout_reports.push(PayoutReport.create(num_payments: 10))
    end
    
    assert_equal PayoutReport.total_payments.to_s, "40"
  end
end

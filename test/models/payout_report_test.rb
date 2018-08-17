require "test_helper"

class PayoutReportTest < ActiveSupport::TestCase
  test "#total_amount returns the total amount ever paid " do
    payout_reports  = []
    4.times do
      payout_reports.push(PayoutReport.create(amount: 10))
    end

    assert_equal PayoutReport.total_amount, 40
  end

  test "#total_payments returns the total amount ever paid " do
    payout_reports  = []
    4.times do
      payout_reports.push(PayoutReport.create(num_payments: 10))
    end
    
    assert_equal PayoutReport.total_payments, 40
  end

  test "#total_fees returns the total amount ever paid " do
    payout_reports  = []
    4.times do
      payout_reports.push(PayoutReport.create(fees: 10))
    end
    
    assert_equal PayoutReport.total_fees, 40
  end

end
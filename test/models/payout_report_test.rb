# typed: false
require "test_helper"

class PayoutReportTest < ActiveSupport::TestCase
  test "#total_amount returns the total amount ever paid" do
    assert_equal PayoutReport.total_amount.to_s, "270000000100"
  end

  test "#total_fees returns the total amount ever paid " do
    assert_equal PayoutReport.total_fees.to_s, "13500000000"
  end

  test "#total_payments returns the total amount ever paid " do
    assert_equal PayoutReport.total_payments, PotentialPayment.count
  end

  def test_status_values
    [
      {value: "Error with anything", valid: true},
      {value: "Enqueued", valid: true},
      {value: "Complete", valid: true},
      {value: "Invalid", valid: false}
    ].each do |obj|
      model = payout_reports(:one)
      assert model.valid?
      model.status = obj[:value]

      if obj[:valid]
        assert model.valid?
      else
        assert !model.valid?
      end
    end
  end
end

require 'test_helper'

class PayoutReportJsonBuilderTest < ActiveSupport::TestCase
  test "builds the report json" do
    payout_report = payout_reports(:one)

    payout_json = JsonBuilders::PayoutReportJsonBuilder.new(payout_report: payout_report).build

    payout_json.each do |potential_payment|
      assert_equal "90000000000", potential_payment["probi"]
      assert_equal "bc29c05c-e6aa-450c-8ea2-7d598666fac0", potential_payment["address"]
      assert_equal "6c6bb015-f307-4440-9935-552a9fa184cb", potential_payment["uphold_id"]
    end
  end
end

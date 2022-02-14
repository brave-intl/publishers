# typed: false
require "test_helper"

class EyeshadeBaseBalanceTest < ActiveSupport::TestCase
  test "#init" do
    inst = Eyeshade::BaseBalance.new({btc: BigDecimal("123.012")}, "bat")
    assert_instance_of(BigDecimal, inst.amount_bat)
    assert_instance_of(BigDecimal, inst.display_bat)
  end
end

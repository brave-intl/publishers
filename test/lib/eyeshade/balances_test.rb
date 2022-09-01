# typed: false

require "test_helper"

class EyeshadeBalancesTest < ActiveSupport::TestCase
  include Eyeshade::Types
  # I'm leaving wallet nomenclature here, balances is basically a v2 of eyeshade wallet that
  # is intended to be backwards compatible
  let(:wallet) { EyeshadeHelper::Mocks.balances }
  let(:existing_methods) { [:rates, :default_currency, :channel_balances, :referral_balance, :overall_balance, :contribution_balance, :last_settlement_balance, :accounts] }

  test "#init" do
    assert_instance_of(Eyeshade::Balances, wallet)
    existing_methods.each do |method|
      assert_respond_to(wallet, method)
    end
  end

  test "#overall_balance" do
    assert_kind_of(ConvertedBalance, wallet.overall_balance)
    assert wallet.overall_balance.amount_bat > 0
    assert wallet.overall_balance.fees_bat > 0
  end

  test "#channel_balances" do
    result = wallet.channel_balances
    assert_kind_of(Array, result)
    assert result[0].amount_bat > 0
    assert result[0].fees_bat > 0
  end

  test "#referral_balance" do
    assert_kind_of(ConvertedBalance, wallet.referral_balance)
    assert wallet.referral_balance.amount_bat > 0
    assert wallet.referral_balance.fees_bat == 0
  end
end

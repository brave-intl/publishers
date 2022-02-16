# typed: false
require "test_helper"
require "eyeshade/wallet"
require "eyeshade/base_balance"
require "eyeshade/overall_balance"
require "eyeshade/channel_balance"
require "eyeshade/referral_balance"
require "eyeshade/last_settlement_balance"

class WalletTest < ActiveSupport::TestCase
  rates = EyeshadeHelper::Ratio.rates
  accounts = EyeshadeHelper::Balances.accounts
  transactions = EyeshadeHelper::Transactions.transactions
  test_wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: "USD")

  test "channel_balances have correct BAT and probi amounts" do
    assert_equal test_wallet.channel_balances.count, 2

    test_wallet.channel_balances.each do |channel_identifier, channel_balance|
      assert_equal (channel_balance.amount_probi + channel_balance.fees_probi).to_s, "58217204799751874334"
      assert_equal channel_balance.amount_bat.to_s, "55.306344559764280618"
      assert_equal channel_balance.fees_bat.to_s, "2.910860239987593716"
      assert_equal channel_balance.amount_default_currency.to_s, "13.0736640114375707375771402950857336"
      assert_equal channel_balance.fees_default_currency.to_s, "0.6880875795493458281193542960875632"
      assert_equal channel_balance.default_currency, "USD"
    end
  end

  test "referral_balance has correct BAT and probi amounts" do
    referral_balance = test_wallet.referral_balance
    assert_equal referral_balance.amount_probi, 58217204799751874334
    assert_equal referral_balance.amount_bat.to_s, "58.217204799751874334"
    assert_equal referral_balance.fees_bat, 0.00
    assert_equal referral_balance.fees_probi, 0
    assert_equal referral_balance.default_currency, "USD"
    assert_equal referral_balance.amount_default_currency.to_s, "13.7617515909869165656964945911732968"
    assert_equal referral_balance.fees_default_currency, 0.00
  end

  test "overall balance has correct BAT and probi amounts" do
    total_balance_probi = accounts.count.times.sum { 58217204799751874334 }
    total_fees_probi = accounts.count { |account| account["account_type"] == Eyeshade::BaseBalance::CHANNEL }.times.sum { 2910860239987593716 }
    overall_balance = test_wallet.overall_balance
    assert_equal (overall_balance.amount_probi + overall_balance.fees_probi), total_balance_probi
    assert_equal overall_balance.fees_probi, total_fees_probi
  end

  test "last settlement balance has correct timestamp and amount" do
    last_settlement_balance = test_wallet.last_settlement_balance
    assert_equal last_settlement_balance.timestamp, 1544169600
    assert_equal last_settlement_balance.amount_bat.to_s, "749.007010384244866026"
    assert_equal last_settlement_balance.amount_settlement_currency.to_s, "151.24"
  end
end

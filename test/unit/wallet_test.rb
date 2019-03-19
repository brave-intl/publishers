require "test_helper"
require "eyeshade/wallet"
require "eyeshade/base_balance"
require "eyeshade/overall_balance"
require "eyeshade/channel_balance"
require "eyeshade/referral_balance"
require "eyeshade/last_settlement_balance"

class WalletTest < ActiveSupport::TestCase
  wallet_info = {
      "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
      },
      "status" => {
          "provider" => "uphold",
          "action" => "re-authorize"
      },
      "wallet" => {
          "provider" => "uphold",
          "authorized" => true,
          "defaultCurrency" => 'USD',
          "possibleCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ],
          "scope" => 'cards:write'
      }
  }

  accounts = [
    {
      "account_id"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
      "account_type"=>"channel",
      "balance"=> "58.217204799751874334"
    },
    {
      "account_id" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
      "account_type" => "channel",
      "balance" => "58.217204799751874334"
    },
    {
      "account_id" => "publishers#uuid:ef060682-bafc-4f9b-acc7-77baec5e8d50",
      "account_type" => "owner",
      "balance" => "58.217204799751874334"
    }
  ]

  transactions = [{"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"payout for referrals",
                   "channel"=>"publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
                   "amount"=>"-94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"18.81",
                   "type"=>"referral_settlement"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"contributions in month x",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"294.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"contribution"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"settlement fees for contributions",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"-14.730859107490318795",
                   "settlement_currency"=>"ETH",
                   "type"=>"fee"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"payout for contributions",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"-279.886323042316057109",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"56.81",
                   "type"=>"contribution_settlement"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"referrals in month x",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"referral"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"payout for referrals",
                   "channel"=>"publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
                   "amount"=>"-94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"18.81",
                   "type"=>"referral_settlement"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"contributions in month x",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"294.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"contribution"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"settlement fees for contributions",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"-14.730859107490318795",
                   "settlement_currency"=>"ETH",
                   "type"=>"fee"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"payout for contributions",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"-279.886323042316057109",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"56.81",
                   "type"=>"contribution_settlement"},
                  {"created_at"=>"2018-11-07 00:00:00 -0800",
                   "description"=>"referrals in month x",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"referral"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"payout for referrals",
                   "channel"=>"publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
                   "amount"=>"-94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"18.81",
                   "type"=>"referral_settlement"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"settlement fees for contributions",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"-14.730859107490318795",
                   "settlement_currency"=>"ETH",
                   "type"=>"fee"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"payout for contributions",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"-279.886323042316057109",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"56.81",
                   "type"=>"contribution_settlement"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"referrals in month x",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"referral"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"payout for referrals",
                   "channel"=>"publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
                   "amount"=>"-94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"18.81",
                   "type"=>"referral_settlement"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"contributions in month x",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"294.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"contribution"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"settlement fees for contributions",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"-14.730859107490318795",
                   "settlement_currency"=>"ETH",
                   "type"=>"fee"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"payout for contributions",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"-279.886323042316057109",
                   "settlement_currency"=>"ETH",
                   "settlement_amount"=>"56.81",
                   "type"=>"contribution_settlement"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"referrals in month x",
                   "channel"=>"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
                   "amount"=>"94.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"referral"},
                  {"created_at"=>"2018-12-07 00:00:00 -0800",
                   "description"=>"contributions in month x",
                   "channel"=>"youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
                   "amount"=>"294.617182149806375904",
                   "settlement_currency"=>"ETH",
                   "type"=>"contribution"}]

  test_wallet = Eyeshade::Wallet.new(wallet_info: wallet_info, accounts: accounts, transactions: transactions)
  empty_wallet = Eyeshade::Wallet.new(wallet_info: {}, accounts: {})

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
    total_fees_probi = accounts.select {|account| account["account_type"] == Eyeshade::BaseBalance::CHANNEL}.count.times.sum { 2910860239987593716 }
    overall_balance = test_wallet.overall_balance
    assert_equal (overall_balance.amount_probi + overall_balance.fees_probi), total_balance_probi
    assert_equal overall_balance.fees_probi, total_fees_probi
  end

  test "last settlement balance has correct timestamp and amount" do
    last_settlement_balance = test_wallet.last_settlement_balance
    assert_equal last_settlement_balance.timestamp, 1544169600
    assert_equal last_settlement_balance.amount_bat.to_s, "151.24"
    assert_equal last_settlement_balance.amount_settlement_currency.to_s, "0.12028587285273821508"
  end

  test "supports action" do
    assert_equal('re-authorize', test_wallet.action)
  end

  test "handles initialization with empty wallet details" do
    assert empty_wallet.possible_currencies.is_a?(Array)
    assert empty_wallet.address.is_a?(String)
  end

  test "parses wallet status and details" do
    assert_equal "re-authorize", test_wallet.action
    assert_equal true, test_wallet.authorized?
    assert_equal "uphold", test_wallet.provider
    assert_equal 'cards:write', test_wallet.scope
    assert_equal "USD", test_wallet.default_currency
    assert_equal [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ], test_wallet.possible_currencies
  end
end

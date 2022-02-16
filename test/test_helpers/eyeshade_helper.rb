# typed: false
module EyeshadeHelper
  def stub_eyeshade_transactions_response(publisher:, transactions: [])
    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/#{URI.encode_www_form_component(publisher.owner_identifier)}/transactions")
      .to_return(status: 200, body: transactions.to_json, headers: {})
  end

  def stub_eyeshade_balances_response(publisher:, balances: [])
    accounts = [publisher.owner_identifier] + publisher.channels.verified.map { |channel| channel.details.channel_identifier }
    stub_request(:post, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances")
      .with(body: {account: accounts, pending: true})
      .to_return(status: 200, body: balances.to_json)
  end

  def stub_all_eyeshade_wallet_responses(publisher:, wallet: {}, balances: [], transactions: [])
    stub_eyeshade_transactions_response(publisher: publisher, transactions: transactions)
    stub_eyeshade_balances_response(publisher: publisher, balances: balances)
  end

  module Ratio
    extend T::Sig

    sig { returns(::Ratio::Ratio::RESULT_TYPE) }
    def self.rates
      {
        "BTC" => "0.00005418424016883016",
        "ETH" => "0.000795331082073117",
        "USD" => "0.2363863335301452",
        "EUR" => "0.20187818378874756",
        "GBP" => "0.1799810085548496"
      }
    end
  end

  module Balances
    extend T::Sig

    sig { returns(::PublisherBalanceGetter::RESULT_TYPE) }
    def self.accounts
      [
        {
          "account_id" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
          "account_type" => "channel",
          "balance" => "58.217204799751874334"
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
    end
  end

  module Transactions
    def self.transactions
      [{"created_at" => "2018-11-07 00:00:00 -0800",
                   "description" => "payout for referrals",
                   "channel" => "publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
                   "amount" => "-94.617182149806375904",
                   "settlement_currency" => "ETH",
                   "settlement_amount" => "18.81",
                   "type" => "referral_settlement"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "contributions in month x",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "294.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "contribution"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "settlement fees for contributions",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "-14.730859107490318795",
     "settlement_currency" => "ETH",
     "type" => "fee"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "payout for contributions",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "-279.886323042316057109",
     "settlement_currency" => "ETH",
     "settlement_amount" => "56.81",
     "type" => "contribution_settlement"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "referrals in month x",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "94.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "referral"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "payout for referrals",
     "channel" => "publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
     "amount" => "-94.617182149806375904",
     "settlement_currency" => "ETH",
     "settlement_amount" => "18.81",
     "type" => "referral_settlement"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "contributions in month x",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "294.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "contribution"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "settlement fees for contributions",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "-14.730859107490318795",
     "settlement_currency" => "ETH",
     "type" => "fee"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "payout for contributions",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "-279.886323042316057109",
     "settlement_currency" => "ETH",
     "settlement_amount" => "56.81",
     "type" => "contribution_settlement"},
    {"created_at" => "2018-11-07 00:00:00 -0800",
     "description" => "referrals in month x",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "94.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "referral"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "payout for referrals",
     "channel" => "publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
     "amount" => "-94.617182149806375904",
     "settlement_currency" => "ETH",
     "settlement_amount" => "18.81",
     "type" => "referral_settlement"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "settlement fees for contributions",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "-14.730859107490318795",
     "settlement_currency" => "ETH",
     "type" => "fee"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "payout for contributions",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "-279.886323042316057109",
     "settlement_currency" => "ETH",
     "settlement_amount" => "56.81",
     "type" => "contribution_settlement"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "referrals in month x",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "94.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "referral"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "payout for referrals",
     "channel" => "publishers#uuid:8a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
     "amount" => "-94.617182149806375904",
     "settlement_currency" => "ETH",
     "settlement_amount" => "18.81",
     "type" => "referral_settlement"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "contributions in month x",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "294.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "contribution"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "settlement fees for contributions",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "-14.730859107490318795",
     "settlement_currency" => "ETH",
     "type" => "fee"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "payout for contributions",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "-279.886323042316057109",
     "settlement_currency" => "ETH",
     "settlement_amount" => "56.81",
     "type" => "contribution_settlement"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "referrals in month x",
     "channel" => "youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw",
     "amount" => "94.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "referral"},
    {"created_at" => "2018-12-07 00:00:00 -0800",
     "description" => "contributions in month x",
     "channel" => "youtube#channel:UCOo92t8m-tWKgmw256q7mxw",
     "amount" => "294.617182149806375904",
     "settlement_currency" => "ETH",
     "type" => "contribution"}]
    end
  end
end

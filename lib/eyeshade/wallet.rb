# typed: true
require "eyeshade/base_balance"
require "eyeshade/contribution_balance"
require "eyeshade/overall_balance"
require "eyeshade/channel_balance"
require "eyeshade/referral_balance"
require "eyeshade/last_settlement_balance"

module Eyeshade
  class Wallet
    extend T::Sig

    attr_reader :rates,
      :channel_balances,
      :contribution_balance,
      :referral_balance,
      :overall_balance,
      :last_settlement_balance

    sig { params(rates: Ratio::Ratio::RESULT_TYPE, accounts: PublisherBalanceGetter::RESULT_TYPE, transactions: T::Array[T.untyped], default_currency: T.nilable(String)).void }
    def initialize(rates: {}, accounts: [], transactions: [], default_currency: nil)
      @rates = rates # (Jon Staples) I've handled the expected value element at the level of the PublisherWalletGetter
      @default_currency = default_currency # Can this really ever be nil?
      @channel_balances = {}
      accounts.select { |account| account["account_type"] == Eyeshade::BaseBalance::CHANNEL }.each do |account|
        @channel_balances[account["account_id"]] = Eyeshade::ChannelBalance.new(@rates, @default_currency, account)
      end
      @referral_balance = Eyeshade::ReferralBalance.new(@rates, @default_currency, accounts)
      @overall_balance = Eyeshade::OverallBalance.new(@rates, @default_currency, accounts)
      @contribution_balance = Eyeshade::ContributionBalance.new(@rates, @default_currency, accounts)
      @last_settlement_balance = Eyeshade::LastSettlementBalance.new(rates: @rates, default_currency: @default_currency, transactions: transactions)
    end
  end
end

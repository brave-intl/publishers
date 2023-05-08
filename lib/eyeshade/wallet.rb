# typed: true

require "eyeshade/base_balance"
require "eyeshade/contribution_balance"
require "eyeshade/overall_balance"
require "eyeshade/channel_balance"
require "eyeshade/referral_balance"
require "eyeshade/last_settlement_balance"

module Eyeshade
  class Wallet
    attr_reader :rates,
      :channel_balances,
      :contribution_balance,
      :referral_balance,
      :overall_balance,
      :last_settlement_balance

    def initialize(rates: {}, accounts: [], transactions: [], default_currency: nil)
      # Wallet information
      @rates = ActiveSupport::HashWithIndifferentAccess.new(rates)

      @default_currency = default_currency

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

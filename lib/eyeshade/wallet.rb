require 'eyeshade/base_balance'
require "eyeshade/contribution_balance"
require "eyeshade/overall_balance"
require "eyeshade/channel_balance"
require "eyeshade/referral_balance"
require "eyeshade/last_settlement_balance"

module Eyeshade
  class Wallet
    attr_reader :rates,
                :channel_balances,
                :rates,
                :contribution_balance,
                :referral_balance,
                :overall_balance,
                :last_settlement_balance

    def initialize(wallet_info:, accounts: [], transactions: [], uphold_connection: nil)
      # Wallet information
      @rates = wallet_info["rates"] || {}
      @possible_currencies = wallet_info.dig("wallet", "possibleCurrencies") || []
      @channel_balances = {}
      accounts.select { |account| account["account_type"] == Eyeshade::BaseBalance::CHANNEL }.each do |account|
        @channel_balances[account["account_id"]] = Eyeshade::ChannelBalance.new(rates, @default_currency, account)
      end

      @referral_balance = Eyeshade::ReferralBalance.new(rates, @default_currency, accounts)
      @overall_balance = Eyeshade::OverallBalance.new(rates, @default_currency, accounts)
      @contribution_balance = Eyeshade::ContributionBalance.new(rates, @default_currency, accounts)

      @last_settlement_balance = Eyeshade::LastSettlementBalance.new(rates, @default_currency, transactions)
    end
  end
end

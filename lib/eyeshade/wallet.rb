require 'eyeshade/base_balance'
require "eyeshade/overall_balance"
require "eyeshade/channel_balance"
require "eyeshade/referral_balance"
require "eyeshade/last_settlement_balance"

module Eyeshade
  class Wallet
    attr_reader :action,
                :rates,
                :address,
                :provider,
                :scope,
                :default_currency,
                :available_currencies,
                :possible_currencies,
                :channel_balances,
                :rates,
                :status,
                :contribution_balance,
                :referral_balance,
                :overall_balance,
                :last_settlement_balance,
                :last_settlement_date,
                :uphold_id,
                :uphold_account_status

    def initialize(wallet_info:, accounts: [], transactions: [])
      # Wallet information
      @rates = wallet_info["rates"] || {}
      @authorized = wallet_info.dig("wallet", "authorized")
      @provider = wallet_info.dig("wallet", "provider") # Wallet provider e.g. Uphold
      @scope = wallet_info.dig("wallet", "scope") # Permissions e.g. cards:read, cards:write
      @default_currency = wallet_info.dig("wallet", "defaultCurrency")

      # TODO: remove
      @default_currency = "USD"

      @available_currencies = wallet_info.dig("wallet", "availableCurrencies") || []
      @possible_currencies = wallet_info.dig("wallet", "possibleCurrencies") || []
      @address = wallet_info.dig("wallet", "address") || ""
      @is_member = wallet_info.dig("wallet", "isMember") || false
      @uphold_id = wallet_info.dig("wallet", "id")
      @uphold_account_status = wallet_info.dig("wallet", "status")
      @action = wallet_info.dig("status","action")
      @channel_balances = {}
      accounts.select { |account| account["account_type"] == Eyeshade::BaseBalance::CHANNEL }.each do |account|
        @channel_balances[account["account_id"]] = Eyeshade::ChannelBalance.new(rates, @default_currency, account)
      end

      @referral_balance = Eyeshade::ReferralBalance.new(rates, @default_currency, accounts)
      @overall_balance = Eyeshade::OverallBalance.new(rates, @default_currency, accounts)
      @contribution_balance = Eyeshade::ContributionBalance.new(rates, @default_currency, accounts)

      @last_settlement_balance = Eyeshade::LastSettlementBalance.new(rates, @default_currency, transactions)
    end

    def authorized?
      @authorized == true
    end

    def blocked?
      @uphold_account_status == 'blocked'
    end

    def is_a_member?
      @uphold_account_status.present? && @is_member
    end

    def not_a_member?
      !is_a_member?
    end

    def currency_is_possible_but_not_available?(currency)
      @available_currencies.exclude?(currency) && @possible_currencies.include?(currency)
    end
  end
end

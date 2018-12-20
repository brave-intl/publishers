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
                :referral_balance,
                :overall_balance,
                :last_settlement_balance,
                :last_settlement_date

    def initialize(wallet_info:, accounts: [], transactions: [])
      # Wallet information
      @rates = wallet_info["rates"] || {}
      @authorized = wallet_info.dig("wallet", "authorized")
      @provider = wallet_info.dig("wallet", "provider") # Wallet provider e.g. Uphold
      @scope = wallet_info.dig("wallet", "scope") # Permissions e.g. cards:read, cards:write
      @default_currency = wallet_info.dig("wallet", "defaultCurrency")
      @available_currencies = wallet_info.dig("wallet", "availableCurrencies") || []
      @possible_currencies = wallet_info.dig("wallet", "possibleCurrencies") || []
      @address = wallet_info.dig("wallet", "address") || ""
      @action = wallet_info.dig("status","action")

      @channel_balances = {}
      accounts.select { |account| account["account_type"] == Eyeshade::BaseBalance::CHANNEL }.each do |account|
        @channel_balances[account["account_id"]] = Eyeshade::ChannelBalance.new(rates, @default_currency, account)
      end

      @referral_balance = Eyeshade::ReferralBalance.new(rates, @default_currency, accounts)
      @overall_balance = Eyeshade::OverallBalance.new(rates, @default_currency, accounts)

      @last_settlement_balance = Eyeshade::LastSettlementBalance.new(rates, @default_currency, transactions)
    end

    def authorized?
      @authorized == true
    end

    def currency_is_possible_but_not_available?(currency)
      @available_currencies.exclude?(currency) && @possible_currencies.include?(currency)
    end
  end
end

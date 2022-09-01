# typed: true

# No fees applied
#
# MARKED FOR DEPRECATION:
# lib/eyeshade/balances.rb consolidates this functionality but is yet to be fully vetted and implemented

module Eyeshade
  class ReferralBalance < BaseBalance
    attr_reader :amount_usd

    def initialize(rates, default_currency, accounts)
      super(rates, default_currency)
      owner_account = accounts.find { |account| account["account_type"] == OWNER } || {}

      @amount_bat = if owner_account["balance"].nil?
        BigDecimal("0")
      else
        owner_account["balance"].to_d
      end

      @fees_bat = BigDecimal("0")
      @amount_probi = bat_to_probi(@amount_bat)
      @fees_probi = 0
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @fees_default_currency = BigDecimal("0.00")
      @amount_usd = convert(@amount_bat, "USD")
    end
  end
end

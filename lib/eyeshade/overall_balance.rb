# typed: true

# Fees applied to channel balances
#
# MARKED FOR DEPRECATION:
# lib/eyeshade/balances.rb consolidates this functionality but is yet to be fully vetted and implemented
module Eyeshade
  class OverallBalance < BaseBalance
    attr_reader :amount_usd

    def initialize(rates, default_currency, accounts)
      super(rates, default_currency)

      accounts.each do |account|
        if account["account_type"] == CHANNEL
          channel_balance = Eyeshade::ChannelBalance.new(@rates, @default_currency, account)
          @amount_probi += channel_balance.amount_probi
          @fees_probi += channel_balance.fees_probi
        else
          referral_balance = Eyeshade::ReferralBalance.new(@rates, @default_currency, accounts)
          @amount_probi += referral_balance.amount_probi
        end
      end

      @amount_bat = probi_to_bat(@amount_probi)
      @fees_bat = probi_to_bat(@fees_probi)
      @amount_usd = convert(@amount_bat, "USD")
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @fees_default_currency = convert(@fees_bat, @default_currency)
    end
  end
end

# Fees applied to channel balances
module Eyeshade
  class OverallBalance < BaseBalance
    def initialize(rates, default_currency, accounts)
      super(rates, default_currency)

      @amount_probi = 0
      @fees_probi = 0

      accounts.each do |account|
        if account["account_type"] == CHANNEL
          channel_balance = Eyeshade::ChannelBalance.new(@rates, @default_currency, account)
          @amount_probi = @amount_probi + channel_balance.amount_probi
          @fees_probi = @fees_probi + channel_balance.fees_probi
        else
          referral_balance = Eyeshade::ReferralBalance.new(@rates, @default_currency, accounts)
          @amount_probi = @amount_probi + referral_balance.amount_probi
        end
      end

      @amount_bat = probi_to_bat(@amount_probi)
      @fees_bat = probi_to_bat(@fees_probi)
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @fees_default_currency = convert(@fees_bat, @default_currency)
    end
  end
end

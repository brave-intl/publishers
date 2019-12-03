# No fees applied
module Eyeshade
  class ReferralBalance < BaseBalance
    def initialize(rates, default_currency, accounts)
      super(rates, default_currency)
      owner_account = accounts.select { |account| account["account_type"] == OWNER}.first || {}

      if owner_account["balance"].nil?
        @amount_bat = 0.to_d
      else
        @amount_bat = owner_account["balance"].to_d
      end

      @fees_bat = 0.to_d
      @amount_probi = bat_to_probi(@amount_bat)
      @fees_probi = 0
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @fees_default_currency = 0.00.to_d
    end
  end
end

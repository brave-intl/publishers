# Fees applied to channel balances
module Eyeshade
  class ContributionBalance < BaseBalance
    def initialize(rates, default_currency, accounts)
      super(rates, default_currency)

      channel_accounts = accounts.select { |account| account["account_type"] == CHANNEL}

      channel_accounts.each do |account|
        channel_balance = Eyeshade::ChannelBalance.new(@rates, @default_currency, account)
        @amount_probi = @amount_probi + channel_balance.amount_probi
        @fees_probi = @fees_probi + channel_balance.fees_probi
      end

      @amount_bat = probi_to_bat(@amount_probi)
      @fees_bat = probi_to_bat(@fees_probi)
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @fees_default_currency = convert(@fees_bat, @default_currency)
    end
  end
end

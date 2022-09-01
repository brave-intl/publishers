# typed: true

# Fees applied to channel balances
module Eyeshade
  class ContributionBalance < BaseBalance
    attr_reader :amount_usd
    attr_reader :channel_amounts_usd

    def initialize(rates, default_currency, accounts)
      super(rates, default_currency)

      channel_accounts = accounts.select { |account| account["account_type"] == CHANNEL }

      @channel_amounts_usd = []

      channel_accounts.each do |account|
        channel_balance = Eyeshade::ChannelBalance.new(@rates, @default_currency, account)
        @channel_amounts_usd << convert(probi_to_bat(channel_balance.amount_probi), "USD")
        @amount_probi += channel_balance.amount_probi
        @fees_probi += channel_balance.fees_probi
      end

      @amount_bat = probi_to_bat(@amount_probi)
      @fees_bat = probi_to_bat(@fees_probi)
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @amount_usd = convert(@amount_bat, "USD")
      @fees_default_currency = convert(@fees_bat, @default_currency)
    end
  end
end

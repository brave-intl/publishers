# Fees applied
module Eyeshade
  class ChannelBalance < BaseBalance
    def initialize(rates, default_currency, account)
      super(rates, default_currency)
      total_probi = bat_to_probi(account["balance"].to_d)
      amount_and_fees = calculate_fees(total_probi)
      @amount_probi = amount_and_fees["amount"]
      @fees_probi = amount_and_fees["fees"]

      @amount_bat = probi_to_bat(@amount_probi)
      @fees_bat = probi_to_bat(@fees_probi)
      @amount_default_currency = convert(@amount_bat, @default_currency)
      @fees_default_currency = convert(@fees_bat, @default_currency)
    end
  end
end

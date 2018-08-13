module Eyeshade
  class Wallet
    attr_reader :action,
                :provider,
                :scope,
                :default_currency,
                :available_currencies,
                :possible_currencies,
                :contribution_balance,
                :owner_balance,
                :channel_balances,
                :rates,
                :last_settlement_balance,
                :last_settlement_date

    def initialize(wallet_json:, channels_json:) # change to balance json
      details_json = wallet_json["wallet"] || {}
      @authorized = details_json["authorized"]
      @provider = details_json["provider"]
      @scope = details_json["scope"]
      @default_currency = details_json["defaultCurrency"]
      @available_currencies = details_json["availableCurrencies"] || []
      @possible_currencies = details_json["possibleCurrencies"] || []

      @rates = wallet_json["rates"] || {}

      status_json = wallet_json["status"] || {}
      @action = status_json["action"]

      @channel_balances = {}
      @owner_balance = 0

      # Add empty balances for verified channels with no balance
      if channels_json.present? 
        channels_json.each do |channel_json|
          channel_identifier = channel_json["account"]
          channel_balance = channel_json["balance"]
          @channel_balances[channel_identifier] = channel_balance

          @owner_balance = ('%2.f' % (@owner_balance + channel_balance.to_f)).to_f
        end
      end

      if wallet_json["lastSettlement"]
        @last_settlement_balance = wallet_json["lastSettlement"]["amount"] / BigDecimal.new('1.0e18') # lastSettlement value is still in probi
        @last_settlement_date = Time.at(wallet_json["lastSettlement"]["timestamp"]/1000).to_datetime
      end
    end

    def authorized?
      @authorized == true
    end

    def currency_is_possible_but_not_available?(currency)
      @available_currencies.exclude?(currency) && @possible_currencies.include?(currency)
    end

    def convert_balance(balance, currency_code)
      return ('%.2f' % balance) if (currency_code == "BAT" || currency_code == nil)

      rate = rates[currency_code.upcase]
      raise "Missing currency conversion rate #{currency_code.upcase} for #{@balance_json}" unless rate
      converted_balance = '%.2f' % (balance.to_f * rate)
      converted_balance
    end
  end
end

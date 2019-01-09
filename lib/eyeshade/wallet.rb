require "eyeshade/balance"

module Eyeshade
  class Wallet
    attr_reader :action,
                :address,
                :provider,
                :scope,
                :default_currency,
                :available_currencies,
                :possible_currencies,
                :contribution_balance,
                :channel_balances,
                :rates,
                :last_settlement_balance,
                :last_settlement_date

    def initialize(wallet_json:, channel_json:)
      details_json = wallet_json["wallet"] || {}
      @authorized = details_json["authorized"]
      @provider = details_json["provider"]
      @scope = details_json["scope"]
      @default_currency = details_json["defaultCurrency"]
      @available_currencies = details_json["availableCurrencies"] || []
      @possible_currencies = details_json["possibleCurrencies"] || []
      @address = details_json["address"] || ""
      @is_member = details_json["isMember"] || false

      status_json = wallet_json["status"] || {}
      @action = status_json["action"]

      balance_json = wallet_json["contributions"] || {}
      @rates = balance_json["rates"] = wallet_json["rates"] || {}

      @contribution_balance = Eyeshade::Balance.new(balance_json: balance_json)

      @channel_balances = {}
      channel_json.each do |identifier, json|
        @channel_balances[identifier] = Eyeshade::Balance.new(balance_json: json)
      end

      if wallet_json["lastSettlement"]
        @last_settlement_balance = Eyeshade::Balance.new(balance_json: wallet_json["lastSettlement"].merge({'rates' => @rates}), apply_fee: false)
        @last_settlement_date = Time.at(wallet_json["lastSettlement"]["timestamp"]/1000).to_datetime
      end
    end

    def authorized?
      @authorized == true
    end

    def is_a_member?
      @is_member
    end

    def not_a_member?
      !is_a_member?
    end

    def currency_is_possible_but_not_available?(currency)
      @available_currencies.exclude?(currency) && @possible_currencies.include?(currency)
    end
  end
end

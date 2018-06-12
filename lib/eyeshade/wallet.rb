require "eyeshade/balance"

module Eyeshade
  class Wallet
    attr_reader :wallet_json, :status, :contribution_balance, :wallet_details,
                :channel_json, :channel_balances, :rates, :last_settlement_balance, :last_settlement_date

    def initialize(wallet_json:, channel_json:)
      @wallet_json = wallet_json
      @channel_json = channel_json

      @status = wallet_json["status"].is_a?(Hash) ? wallet_json["status"] : {}
      @rates = wallet_json["rates"].is_a?(Hash) ? wallet_json["rates"] : {}

      if wallet_json["lastSettlement"].is_a?(Hash)
        @last_settlement_balance = Eyeshade::Balance.new(balance_json: wallet_json["lastSettlement"].merge({'rates' => rates}))
        @last_settlement_date = Time.at(wallet_json["lastSettlement"]["timestamp"]/1000).to_datetime
      end

      balance_json = wallet_json["contributions"].is_a?(Hash) ? wallet_json["contributions"] : {}
      balance_json["rates"] = @rates

      @contribution_balance = Eyeshade::Balance.new(balance_json: balance_json)

      @wallet_details = wallet_json["wallet"].is_a?(Hash) ? wallet_json["wallet"] : {}

      @channel_balances = {}
      @channel_json.each do |identifier, json|
        @channel_balances[identifier] = Eyeshade::Balance.new(balance_json: json)
      end
    end
  end
end

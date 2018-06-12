module JsonBuilders
  class WalletJsonBuilder

    attr_reader :wallet

    def initialize(wallet:)
      @wallet = wallet
    end

    def build
      Jbuilder.encode do |json|

        if @wallet.last_settlement_date &&
            @wallet.last_settlement_balance &&
            @wallet.last_settlement_balance.is_a?(Eyeshade::Balance)
          json.lastSettlement do
            json.date @wallet.last_settlement_date

            last_settlement_balance = @wallet.last_settlement_balance
            json.balance do
              build_balance(json, last_settlement_balance)
            end
          end
        end

        if @wallet.wallet_details['provider']
          json.providerWallet do
            json.provider @wallet.wallet_details['provider']
            json.authorized @wallet.wallet_details['authorized']
            json.defaultCurrency @wallet.wallet_details['defaultCurrency']
            json.rates @wallet.rates
            json.availableCurrencies @wallet.wallet_details['availableCurrencies']
            json.possibleCurrencies @wallet.wallet_details['possibleCurrencies']
            json.scope @wallet.wallet_details['scope']
          end
        end

        json.channelBalances do
          @wallet.channel_balances.each_pair do |identifier, channel_balance|
            build_channel(json, identifier, channel_balance)
          end
        end

        json.status @wallet.status
      end
    end

    private

    def build_balance(json, balance)
      json.probi balance.probi.to_s
    end

    def build_channel(json, identifier, channel_balance)
      json.set! identifier do
        build_balance(json, channel_balance)
      end
    end
  end
end
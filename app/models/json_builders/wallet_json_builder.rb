module JsonBuilders
  class WalletJsonBuilder

    attr_reader :wallet, :publisher

    def initialize(wallet:, publisher:)
      @wallet = wallet
      @publisher = publisher
    end

    def build
      Jbuilder.encode do |json|

        if @wallet.last_settlement_date && @wallet.last_settlement_balance
          json.lastSettlement do
            json.date @wallet.last_settlement_date

            last_settlement_balance = @wallet.last_settlement_balance
            json.balance do
              build_balance(json, last_settlement_balance)
            end
          end
        end

        if @wallet.provider
          json.providerWallet do
            json.provider @wallet.provider
            json.authorized @wallet.authorized?
            json.defaultCurrency @publisher.default_currency
            json.rates @wallet.rates
            json.availableCurrencies @wallet.available_currencies
            json.possibleCurrencies @wallet.possible_currencies
            json.scope @wallet.scope
          end
        end

        json.channelBalances do
          @wallet.channel_balances.each_pair do |identifier, channel_balance|
            build_channel(json, identifier, channel_balance)
          end
        end
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
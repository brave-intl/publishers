# typed: true

module Eyeshade
  class Balances
    include Eyeshade::Types

    CHANNEL = "channel"
    REFERRAL = "owner"

    attr_reader :rates,
      :default_currency,
      :accounts

    def initialize(rates: {}, account_balances: [], transactions: [], default_currency: nil)
      @rates = rates
      @accounts = account_balances
      @account_type_hash = {}
      @default_currency = default_currency
      @amount_probi = 0
      @fees_probi = 0
      @zero = BigDecimal("0")

      @accounts.each do |account|
        type = account.account_type
        if @account_type_hash.fetch(type, nil)
          @account_type_hash[type].append(account)
        else
          @account_type_hash[type] = [account]
        end
      end
    end

    def overall_balance
      balance(source: nil)
    end

    def channel_balances
      @account_type_hash.fetch(CHANNEL, []).map { |account| account_balance(account) }
    end

    def referral_balance
      balance(source: REFERRAL)
    end

    def contribution_balance
      balance(source: "contribution")
    end

    def last_settlement_balance
      balance(source: "settlement")
    end

    private

    def balance(source: nil)
      iterable = if source
        @account_type_hash.fetch(source, [])
      else
        @accounts
      end

      amount_bat = @zero
      fees_bat = @zero
      amount_default_currency = @zero
      amount_usd = @zero

      iterable.each do |account|
        balance = account_balance(account)
        amount_bat += balance.amount_bat
        fees_bat += balance.fees_bat
        amount_default_currency += balance.amount_default_currency
        amount_usd += balance.amount_usd
      end

      ConvertedBalance.new(amount_usd: amount_usd, amount_bat: amount_bat, fees_bat: fees_bat, amount_default_currency: amount_default_currency)
    end

    def account_balance(account)
      total_probi = bat_to_probi(BigDecimal(account.balance))

      amount_and_fees = calculate_fees(total_probi)
      amount_probi = amount_and_fees["amount"]

      fees_probi = if account.account_type == REFERRAL
        0
      else
        amount_and_fees["fees"]
      end

      amount_bat = probi_to_bat(amount_probi)

      fees_bat = probi_to_bat(fees_probi)

      amount_default_currency = convert(amount_bat, @default_currency)
      # fees_default_currency = convert(fees_bat, @default_currency)
      amount_usd = convert(amount_bat, "USD")

      ConvertedBalance.new(amount_usd: amount_usd, amount_bat: amount_bat, fees_bat: fees_bat, amount_default_currency: amount_default_currency)
    end

    def convert(amount_bat, currency)
      return amount_bat if currency == "BAT"
      return @zero if currency.nil?
      rate = @rates[currency]
      return @zero if rate.nil?

      amount_bat * BigDecimal(rate)
    end

    def probi_to_bat(probi)
      probi.to_d / 1E18
    end

    def bat_to_probi(bat)
      (bat * BigDecimal("1.0e18")).to_i
    end

    def calculate_fees(total_probi)
      fees_probi = (total_probi * fee_rate).to_i
      amount_probi = total_probi - fees_probi
      {"amount" => amount_probi, "fees" => fees_probi}
    end

    def fee_rate
      Rails.application.credentials[:fee_rate].to_d
    end
  end
end

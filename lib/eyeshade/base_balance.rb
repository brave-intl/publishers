# typed: true
# frozen_string_literal: true

module Eyeshade
  class BaseBalance
    extend T::Sig

    attr_reader :rates,
      :display_bat, # display only value, should not be used for calculations
      :default_currency,
      :amount_probi,
      :amount_bat,
      :amount_default_currency,
      :fees_probi,
      :fees_bat,
      :fees_default_currency

    # Account types
    CHANNEL = "channel"
    OWNER = "owner"

    # TODO/FIXME: Determine if default currency should be nilable
    # POC: I can share result types by casting them as constants within a class/module...
    sig { params(rates: Ratio::Ratio::RESULT_TYPE, default_currency: T.nilable(String)).void }
    def initialize(rates, default_currency)
      @rates = rates
      @default_currency = default_currency
      @amount_probi = 0
      @fees_probi = 0
      @zero = BigDecimal("0")
      @amount_bat = @zero
      @display_bat = @amount_bat
    end

    sig { params(bat: BigDecimal).returns(BigDecimal) }
    def add_bat(bat)
      @amount_bat += bat
      @amount_probi += bat_to_probi(bat)
      @amount_default_currency += convert(bat, @default_currency) if @default_currency.present?
    end

    private

    sig { params(probi: Integer).returns(BigDecimal) }
    def probi_to_bat(probi)
      bat = probi.to_d / 1E18
      @display_bat = bat < 0 ? @zero : bat
      bat
    end

    sig { params(bat: BigDecimal).returns(Integer) }
    def bat_to_probi(bat)
      (bat * BigDecimal("1.0e18")).to_i
    end

    # FIXME: (Jon Staples) - Not sure what expected types are here, typing causes errors
    sig { params(total_probi: Integer).returns(T::Hash[String, T.untyped]) }
    def calculate_fees(total_probi)
      fees_probi = (total_probi * fee_rate).to_i
      amount_probi = total_probi - fees_probi
      {"amount" => amount_probi, "fees" => fees_probi}
    end

    sig { params(amount_bat: BigDecimal, currency: T.nilable(String)).returns(BigDecimal) }
    def convert(amount_bat, currency)
      return amount_bat if currency == "BAT"
      return @zero if currency.nil?
      rate = @rates[currency]
      return @zero if rate.nil?

      amount_bat * BigDecimal(T.must(rate))
    end

    def fee_rate
      Rails.application.secrets[:fee_rate].to_d
    end
  end
end

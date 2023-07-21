# typed: true
# frozen_string_literal: true

#
# MARKED FOR DEPRECATION:
# lib/eyeshade/balances.rb consolidates this functionality but is yet to be fully vetted and implemented
module Eyeshade
  class BaseBalance
    attr_reader :rates,
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

    def initialize(rates, default_currency)
      @rates = (rates[:payload] && rates[:payload][:bat]) || {}
      @default_currency = default_currency
      @amount_probi = 0
      @fees_probi = 0
    end

    def add_bat(bat)
      @amount_bat += bat
      @amount_probi += bat_to_probi(bat)
      @amount_default_currency += convert(bat, @default_currency) if @default_currency.present?
    end

    private

    # Expects an Integer and returns a BigDecimal
    def probi_to_bat(probi)
      probi.to_d / 1E18
    end

    # Expects a BigDecimal returns an Integer
    def bat_to_probi(bat)
      (bat * BigDecimal("1.0e18")).to_i
    end

    # Expects and returns values with probi unit
    def calculate_fees(total_probi)
      fees_probi = (total_probi * fee_rate).to_i
      amount_probi = total_probi - fees_probi
      {"amount" => amount_probi, "fees" => fees_probi}
    end

    # Expects and returns BigDecimals
    def convert(amount_bat, currency)
      # if no currency is provided, assume BAT
      needed_currency = currency&.downcase || "bat"
      return amount_bat if needed_currency == "bat"
      return if @rates[needed_currency].nil?
      # (Albert Wang): It's possible that the resulting parameter is actually a String,
      # so we'll cast it
      if @rates[currency].is_a? String
        require "bigdecimal"
        amount_bat * BigDecimal(@rates[needed_currency])
      else
        amount_bat * @rates[needed_currency]
      end
    end

    def fee_rate
      Rails.configuration.pub_secrets[:fee_rate].to_d
    end
  end
end

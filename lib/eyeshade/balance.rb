module Eyeshade
  class Balance
    attr_reader :balance_json, :probi, :currency, :altcurrency, :amount, :rates

    def initialize(balance_json:)
      @balance_json = balance_json

      @probi = balance_json['probi'] ? Integer(balance_json['probi']) : 0
      @currency = balance_json['currency']
      @altcurrency = balance_json['altcurrency']
      @amount = balance_json['amount'] ? balance_json['amount'].to_f : 0.0

      @rates = {"BAT" => 1.0}
      if balance_json['rates'].is_a?(Hash)
        balance_json['rates'].each_pair do |k,v|
          @rates[k.upcase] = v.to_f
        end
      end
    end

    def BAT
      @probi / BigDecimal.new('1.0e18')
    end

    def convert_to(currency_code = 'USD')
      rate = rates[currency_code.upcase]
      raise "Missing currency conversion rate #{currency_code.upcase} for #{@balance_json}" unless rate

      self.BAT * rate
    end
  end
end
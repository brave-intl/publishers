module Eyeshade
  class Balance
    attr_reader :balance_json, :probi, :probi_before_fees, :fee, :currency, :altcurrency, :amount, :rates

    def initialize(balance_json:, apply_fee: true)
      @balance_json = balance_json
      @probi_before_fees = balance_json['probi'] ? Integer(balance_json['probi']) : 0

      balance_and_fee = PublisherBalanceFeeCalculator.new(probi: probi_before_fees).perform
      @probi = apply_fee ? balance_and_fee[:balance_after_fee] : @probi_before_fees

      @fee = balance_and_fee[:fee]

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

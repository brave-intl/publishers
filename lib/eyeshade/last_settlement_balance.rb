module Eyeshade
  class LastSettlementBalance < BaseBalance
    attr_reader :date, :amount_settlement_currency, :timestamp, :settlement_currency

    def initialize(rates, default_currency, transactions)
      super(rates, default_currency)

      last_settlement = calculate_last_settlement(transactions)
      @amount_bat = last_settlement["amount_bat"]
      @timestamp = last_settlement["timestamp"]
      @settlement_currency = last_settlement["currency"]
      @amount_settlement_currency = convert(@amount_bat, @settlement_currency)
    end

    private

    def calculate_last_settlement(transactions)
      return {} if transactions == []
       # Find most recent settlement transaction
      last_settlement_date = transactions.select { |transaction|
        transaction["settlement_amount"].present?
      }.last["created_at"].to_date # Eyeshade returns transactions ordered_by created_at

       # Find all settlement transactions that occur within the same month as the last settlement timestamp
      last_settlement_transactions = transactions.select { |transaction|
        transaction["created_at"].to_date.at_beginning_of_month == last_settlement_date.at_beginning_of_month &&
        transaction["settlement_amount"].present?
      }

      # Sum the all the settlement transactions
      last_settlement_currency = last_settlement_transactions&.first["settlement_currency"] || nil
      last_settlement_bat = last_settlement_transactions.map { |transaction|
        transaction["settlement_amount"].to_d
      }.reduce(:+)

      {"amount_bat" => last_settlement_bat, "timestamp" => last_settlement_date.to_time.to_i, "currency" => last_settlement_currency}
    end
  end
end

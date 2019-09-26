module Views
  module User
    class StatementDetail
      include ActiveModel::Model

      attr_accessor :title, :channel, :created_at, :description, :transaction_type, :amount, :settlement_currency,
        :settlement_amount, :settlement_destination_type, :settlement_destination, :transactions
    end
  end
end

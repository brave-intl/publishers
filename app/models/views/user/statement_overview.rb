module Views
  module User
    class StatementOverview
      include ActiveModel::Model
      # include PromosHelper
      # include PublishersHelper

      attr_accessor :earning_period, :payment_date, :destination, :amount, :deposited,
        :currency, :details, :settled_transactions, :raw_transactions, :name, :email

      def initialize(attributes = {})
        super
        build_details
      end

      def as_json(*)
        {
          earning_period: earning_period,
          payment_date: payment_date,
          destination: destination,
          amount: amount.round(2),
          deposited: deposited,
          currency: currency,
          details: details,
          name: name,
          email: email,
          isOpen: false,
          rawTransactions: raw_transactions
        }
      end

      def build_details
        details = []
        grouped_transactions = settled_transactions.group_by { |x| x.transaction_type }

        grouped_transactions.each do |type, results|
          total_amount = 0

          results = results.each do |x|
            x.amount = x.amount.abs unless x.transaction_type == "fees"
            total_amount += x.amount.abs
          end

          details << StatementDetail.new(
            title: I18n.t("publishers.statements.index.#{type}"),
            amount: total_amount,
            transactions: results
          )
        end

        @details = details
      end
    end
  end
end

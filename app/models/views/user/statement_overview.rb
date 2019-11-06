module Views
  module User
    class StatementOverview
      include ActiveModel::Model
      # include PromosHelper
      # include PublishersHelper

      attr_accessor :earning_period, :payment_date, :destination, :total_earned, :deposited,
        :currency, :details, :settled_transactions, :raw_transactions, :name, :email, :total_fees, :total_bat_deposited

      def initialize(attributes = {})
        super
        build_details
      end

      def as_json(*)
        {
          earning_period: earning_period,
          payment_date: payment_date,
          destination: destination,
          deposited: deposited,
          currency: currency,
          details: details,
          name: name,
          email: email,
          isOpen: false,
          rawTransactions: raw_transactions,
          totalEarned: total_earned,
          totalFees: total_fees,
          totalBATDeposited: total_bat_deposited,
        }
      end

      def build_details
        details = []
        grouped_transactions = settled_transactions.group_by { |x| x.transaction_type }

        grouped_transactions.each do |type, results|
          total_amount = 0

          results = results.each do |x|
            x.amount = x.amount.abs unless x.transaction_type == "fees"

            if x.amount.positive?
              total_amount += x.amount.abs
            else
              total_amount -= x.amount.abs
            end
          end

          details << StatementDetail.new(
            title: I18n.t("publishers.statements.index.#{type}"),
            description: I18n.t("publishers.statements.index.#{type}_description"),
            amount: total_amount,
            transactions: results,
            type: type,
          )
        end

        @details = details.sort_by { |x| x.title }
      end
    end
  end
end

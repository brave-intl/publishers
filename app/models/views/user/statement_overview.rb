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
        grouped_channels = settled_transactions.group_by { |x| x.channel }

        grouped_channels.each do |channel, results|
          results = results.sort_by { |x| x.transaction_type }
          contribution = results.detect { |x| x.transaction_type == "contribution_settlement" }
          total_amount = 0

          if contribution
            fees = results.detect { |x| x.transaction_type == "fees" }
            total = contribution.amount.abs + fees.amount.abs

            # Swapping the eyeshaded settled with the actual total that was contributed ()
            contribution.amount = total
          end

          results = results.each do |x|
            x.amount = x.amount.abs unless x.transaction_type == "fees"
            x.transaction_type = I18n.t("publishers.statements.index.#{x.transaction_type}")
            total_amount += x.amount
          end

          details << StatementDetail.new(
            channel: channel,
            amount: total_amount,
            transactions: results
          )
        end

        @details = details
      end
    end
  end
end

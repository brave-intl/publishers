module Views
  module User
    class StatementOverview
      include ActiveModel::Model
      # include PromosHelper
      # include PublishersHelper

      attr_accessor :earning_period, :payment_date, :destination, :amount, :deposited, :currency, :details, :transactions, :name, :email

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
          isOpen: false
        }
      end


      def build_details
        details = []
        grouped_channels = transactions.group_by { |x| x.channel }

        grouped_channels.each do |channel, results|
          results = results.sort_by { |x| x.transaction_type }
          contribution = results.detect { |x| x.transaction_type == "contribution_settlement" }

          if contribution
            contribution_settled = contribution.amount.abs
            fees = results.detect { |x| x.transaction_type == "fees" }
            total = contribution_settled + fees.amount.abs

            # Swapping the settled with the actual total that was contributed.
            contribution.amount = total
          end

          results = results.each do |x|
            x.amount = x.amount.abs unless x.transaction_type == "fees"
            x.transaction_type = I18n.t("publishers.statements.index.#{x.transaction_type}")
          end

          details << StatementDetail.new(
            channel: channel,
            amount: contribution_settled || results.sum { |x| x.amount.abs || 0 },
            transactions: results
          )
        end

        @details = details
      end
    end
  end
end

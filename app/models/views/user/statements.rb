# frozen_string_literal: true

module Views
  module User
    class Statements
      include ActiveModel::Model
      attr_accessor :overviews

      MONTH_FORMAT = "%b %Y"
      YEAR_FORMAT = "%b %e, %Y"

      def initialize(publisher_id)
        publisher = Publisher.find(publisher_id)
        build_statements(publisher)
      end

      def as_json(*)
        {
          overviews: overviews,
        }
      end

      def build_statements(publisher)
        @overviews = []
        statements = PublisherStatementGetter.new(publisher: publisher).perform

        # Here's the problem, sometimes users don't get paid out every month.
        # Because of this user's statements must be grouped in such a way where we aggregate all the previous values until the first payment gets found
        # So here we select all the negative amounts which are when we subtracted from the Eyeshade balance
        payouts = statements.select { |x| x.amount.negative? }.sort_by { |x| x.created_at }
        # Then we group by the month
        grouped = payouts.group_by { |x| x.created_at.at_beginning_of_month }

        grouped.each do |payment_month, entries|
          # We find the previous month that was paid, or the first statement that was generated
          period_start = grouped.keys.reverse.detect { |k| k < payment_month } || statements.first.created_at.at_beginning_of_month

          # Sum all the BAT amounts
          total_amount = entries.sum { |x| x.amount.abs }
          settlement_amount = entries.sum { |x| x.settlement_amount || 0 }

          payout_entry = entries.detect { |x| x.settlement_currency.present? }

          @overviews << StatementOverview.new(
            name: publisher.name,
            email: publisher.email,
            earning_period: "#{period_start.strftime(MONTH_FORMAT)} - #{payment_month.strftime(MONTH_FORMAT)}",
            payment_date: payout_entry.created_at.strftime(YEAR_FORMAT) || '--',
            currency: payout_entry.settlement_currency,
            amount: total_amount,
            deposited: settlement_amount,
            transactions: entries,
          )
        end

        @overviews
      end
    end
  end
end

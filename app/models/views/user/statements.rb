# frozen_string_literal: true

module Views
  module User
    class Statements
      include ActiveModel::Model
      attr_accessor :overviews

      MONTH_FORMAT = "%b %Y"
      YEAR_FORMAT = "%b %e, %Y"

      def initialize(publisher:, details_date: nil)
        @statements = PublisherStatementGetter.new(publisher: publisher).perform
        build_statements(publisher, details_date)
      end

      def as_json(*)
        {
          overviews: overviews,
        }
      end

      def build_statements(publisher, details_date)
        @overviews = []

        # Here's the problem, sometimes users don't get paid out every month.
        # Because of this user's statements must be grouped in such a way where we aggregate all the previous values until the first payment gets found
        # An easy way to do this is to look at the statements which have a negative amount, signifying that we paid them out and subtracted it from their balance.
        payouts = @statements.select { |x| x.amount.negative? }

        # Then we can group the payouts into monthly periods for the statement
        periods = payouts.group_by { |x| x.created_at.at_beginning_of_month }

        periods.each do |payment_month, payout_entries|
          # We find the previous month that was paid, or the first statement that was generated
          period_start = periods.keys.reverse.detect { |k| k < payment_month } || @statements.first.created_at.at_beginning_of_month

          # Sum all the BAT amounts
          total_amount = payout_entries.sum { |x| x.amount.abs }
          settlement_amount = payout_entries.sum { |x| x.settlement_amount || 0 }
          payout_entry = payout_entries.detect { |x| x.settlement_currency.present? }

          @overviews << StatementOverview.new(
            name: publisher.name,
            email: publisher.email,
            earning_period: "#{period_start.strftime(MONTH_FORMAT)} - #{payment_month.strftime(MONTH_FORMAT)}",
            payment_date: payout_entry.created_at.strftime(YEAR_FORMAT) || "--",
            currency: payout_entry.settlement_currency,
            amount: total_amount,
            deposited: settlement_amount,
            settled_transactions: payout_entries.deep_dup,
            raw_transactions: entries(period_start.at_beginning_of_month, payout_entries.last.created_at.at_beginning_of_month),
          )
        end

        @overviews
      end

      def entries(period_start, period_end)
        @statements.select { |x| x.created_at > period_start && x.created_at <= period_end }
      end
    end
  end
end

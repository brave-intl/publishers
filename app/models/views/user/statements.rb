# frozen_string_literal: true

module Views
  module User
    class Statements
      include ActiveModel::Model
      attr_accessor :overviews

      MONTH_FORMAT = "%b %Y"
      YEAR_FORMAT = "%b %e, %Y"

      def initialize(publisher:, details_date: nil)
        build_statements(publisher, details_date)
      end

      def as_json(*)
        {
          overviews: overviews,
        }
      end

      def build_statements(publisher, details_date)
        @overviews = []
        statements = PublisherStatementGetter.new(publisher: publisher).perform

        # Here's the problem, sometimes users don't get paid out every month.
        # Because of this user's statements must be grouped in such a way where we aggregate all the previous values until the first payment gets found
        # An easy way to do this is to look at the statements which have a negative amount, signifying that we paid them out and subtracted it from their balance.
        payouts = statements.select { |x| x.amount.negative? }

        # Then we can group the payouts into monthly periods for the statemen
        periods = payouts.group_by { |x| x.created_at }

        periods.each do |payment_month, payout_entries|
          # We find the previous month that was paid, or the first statement that was generated
          period_start = periods.keys.reverse.detect { |k| k < payment_month } || statements.first.created_at.at_beginning_of_month

          if details_date.present? && details_date.include?(period_start.strftime(MONTH_FORMAT))
            entries = statements.select { |x| x.created_at > period_start.at_beginning_of_month && x.created_at <= payout_entries.last.created_at}
            # Trick for making a deep clone of the object
            entries = Marshal.load(Marshal.dump(entries))
          end

          # Sum all the BAT amounts
          total_amount = payout_entries.sum { |x| x.amount.abs }
          settlement_amount = payout_entries.sum { |x| x.settlement_amount || 0 }

          payout_entry = payout_entries.detect { |x| x.settlement_currency.present? }


          @overviews << StatementOverview.new(
            name: publisher.name,
            email: publisher.email,
            earning_period: "#{period_start.strftime(MONTH_FORMAT)} - #{payment_month.strftime(MONTH_FORMAT)}",
            payment_date: payout_entry.created_at.strftime(YEAR_FORMAT) || '--',
            currency: payout_entry.settlement_currency,
            amount: total_amount,
            deposited: settlement_amount,
            settled_transactions: payout_entries,
            raw_transactions: entries
          )
        end

        @overviews
      end

    end
  end
end

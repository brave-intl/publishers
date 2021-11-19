# typed: ignore
# frozen_string_literal: true

module Views
  module User
    class Statements
      include ActiveModel::Model
      attr_accessor :overviews, :publisher

      def initialize(publisher:)
        @publisher = publisher
        statements = PublisherStatementGetter.new(publisher: @publisher).perform

        earning_periods = group_by_earning_period(statements)

        build_statement_overviews(earning_periods)
      end

      # Here's the problem, sometimes users don't get paid out every month.
      # Because of this user's statements must be grouped in such a way where we aggregate all the previous values until the first payment gets found
      # An easy way to do this is to look at the statements which have a negative amount, signifying that we paid them out and subtracted it from their balance.
      # Then we can group the payouts into monthly periods for the statement
      def group_by_earning_period(statements)
        statements
          .select { |s| s.amount.negative? }
          .group_by { |s| s.earning_period }
      end

      def build_statement_overviews(earning_periods)
        @overviews = []

        earning_periods.each do |payment_month, payout_entries|
          overview = StatementOverview.new(
            publisher_id: @publisher.id,
            name: @publisher.name,
            email: @publisher.email,
            settled_transactions: payout_entries.deep_dup
          )

          total_brave_settled = 0
          settlement_destination = nil

          payout_entries.each do |payout_entry|
            total_brave_settled += payout_entry.amount.abs if payout_entry.eyeshade_settlement?
            settlement_destination ||= payout_entry.settlement_destination

            # Not all payout entries have settlement currency / amount information so on the statement
            # we should only show the entries which have been settled with the currency information
            if payout_entry.settlement_currency && payout_entry.settlement_amount
              overview.deposited[payout_entry.settlement_currency] ||= 0
              overview.deposited[payout_entry.settlement_currency] += payout_entry.settlement_amount

              # It can be confusing for the user to understand where exactly a deposit came from.
              # This provides a breakdown of what transactions made up the settlement for this specific currency.
              # It is shown in a tooltip in the Statement
              overview.deposited_types[payout_entry.settlement_currency] ||= {}
              overview.deposited_types[payout_entry.settlement_currency][payout_entry.transaction_type] ||= 0
              overview.deposited_types[payout_entry.settlement_currency][payout_entry.transaction_type] += payout_entry.settlement_amount.abs
            end

            # Here we sum up (in BAT) all the different transaction types
            # This is shown to the users as the totals from different sections
            overview.totals[payout_entry.transaction_type.to_sym] ||= 0
            overview.totals[payout_entry.transaction_type.to_sym] += payout_entry.amount.abs

            overview.total_earned += payout_entry.amount.abs
          end

          overview.settlement_destination = settlement_destination # Assume that settlement_destination doesn't change

          overview.totals[:total_brave_settled] = total_brave_settled
          overview.bat_total_deposited = overview.total_earned - overview.totals[:fees]

          # Statements are sorted by the created time, so build the details of the overview
          # Then insert it at the beginning of the @overviews array so that users see the newest entry first.
          @overviews.unshift(overview.build_details)
        end
      end
    end
  end
end

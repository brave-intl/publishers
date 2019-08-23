module Views
  module User
    class Statements
      include ActiveModel::Model
      attr_accessor :overviews

      MONTH_FORMAT = "%b %Y"
      YEAR_FORMAT = "%b %e, %Y"

      def initialize(publisher)
        build_statements
      end

      def as_json(*)
        {
          overviews: overviews
        }
      end

      def build_statements
        @overviews = []
        publisher = Publisher.find_by(email: 'user@brave.com')
        statements = PublisherStatementGetter.new(publisher: publisher, statement_period: "all").perform
        statements.map! do |s|
          s["created_at"] = s["created_at"].to_date
          s
        end

        # Here's the problem, sometimes users don't get paid out every month.
        # Because of this user's statements must be grouped in such a way where we aggregate all the previous values until the first payment gets found
        payouts = statements.select { |x| x["amount"].to_d.negative? }.sort_by { |x| x["created_at"] }
        grouped = payouts.group_by { |x| x["created_at"].at_beginning_of_month }

        grouped.each do |payment_month, entries|
          period_start = grouped.keys.reverse.detect { |k| k < payment_month } || statements.first["created_at"].at_beginning_of_month

          total_amount = entries.sum { |x| x["amount"].to_d.abs }

          currency = entries.detect { |x| x.dig("settlement_currency").present? }&.dig("settlement_currency")

          @overviews << StatementOverview.new(
            name: publisher.name,
            email: publisher.email,
            earning_period: "#{period_start.strftime(MONTH_FORMAT)} - #{payment_month.strftime(MONTH_FORMAT)}",
            payment_date: entries.first["created_at"].strftime(YEAR_FORMAT) || '--',
            amount: total_amount,
            deposited: entries.sum { |x| x["settlement_amount"]&.to_d || 0 },
            currency: currency,
            details: build_details(entries),
            # raw: grouped[month_year]
            raw: entries
          )

        end


        @overviews
      end

      def build_details(transactions)
        details = []
        grouped_channels = transactions.group_by { |x| x["channel"] }

        grouped_channels.each do |channel, results|
          contribution = results.detect { |x| x["transaction_type"] == "contribution_settlement" }

          if contribution
            fees = results.detect { |x| x["transaction_type"] == "fees" }
            contribution_settled = contribution.dig("amount").to_d.abs
            total = contribution_settled + fees["amount"].to_d.abs

            results = [
              { "transaction_type" => contribution["transaction_type"] , 'amount' => total },
              { "transaction_type" => fees["transaction_type"], 'amount' => fees["amount"] },
            ]
          end

          results = results.each do |x|
            x["amount"] = x["amount"].to_d.abs unless x["transaction_type"] == "fees"
            x["transaction_type"] = I18n.t("publishers.statements.index.#{x["transaction_type"]}")
          end


          channel = I18n.t("publishers.statements.index.account") if channel.casecmp("all").zero?

          details << StatementDetail.new(
            channel: channel,
            amount: contribution_settled || results.sum(&sum_transactions),
            transactions: results
          )
        end

        # Aggregate everything by channel
        details
      end

      def sum_transactions
        Proc.new { |x| x["amount"].to_d.abs || 0 }
      end

    end
  end
end

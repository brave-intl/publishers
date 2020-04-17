module Views
  module User
    class StatementOverview
      include ActiveModel::Model
      # include PromosHelper
      # include PublishersHelper

      GROUP_START_DATE = Date.new(2019, 10, 1)
      MONTH_FORMAT = "%b %Y".freeze
      YEAR_FORMAT = "%b %e, %Y".freeze

      attr_accessor :earning_period, :payment_date, :destination, :totals, :deposited, :deposited_types, :total_earned,
                    :currency, :details, :settled_transactions, :raw_transactions, :name, :email, :total_fees, :bat_total_deposited

      def initialize(attributes = {})
        super
        populate_default_values
      end

      # Public: Sets default values for the class if value does not exist.
      #
      # Returns nil
      def populate_default_values
        @name ||= ''
        @email ||= ''
        @total_earned ||= 0
        @totals ||= {
          contribution_settlement: 0,
          fees: 0,
          referral_settlement: 0,
          total_brave_settled: 0,
          uphold_contribution_settlement: 0,
        }
        @bat_total_deposited ||= 0
        @deposited ||= {}
        @deposited_types ||= {}
        @settled_transactions ||= []

        brave_settled_date = settled_transactions.detect { |x| x.eyeshade_settlement? }&.created_at
        @payment_date ||= brave_settled_date&.strftime(YEAR_FORMAT)
        earning_period_start_date = settled_transactions.first.earning_period
        @earning_period ||= "#{earning_period_start_date.strftime(MONTH_FORMAT)} - " \
                            "#{brave_settled_date&.strftime(MONTH_FORMAT)}"
      end

      def as_json(*)
        json = super.deep_transform_keys { |k| k.to_s.camelize(:lower) }

        show_rate_cards = payment_date.present? && payment_date.to_date > GROUP_START_DATE
        json.merge({
          deposited: deposited,
          isOpen: false,
          showRateCards: show_rate_cards,
        })
      end

      # Public: Populates the details of the Overview. Groups transaction types together so statement is easier to read.
      #
      # Returns a StatementOverview
      def build_details
        details = []
        grouped_transactions = settled_transactions.group_by { |x| x.transaction_type }
        # Fees are only associated with Contribution Settlement, so let's group the fees explicitly with contributions.
        fees = grouped_transactions.delete("fees")

        grouped_transactions.each do |type, results|
          total_amount = 0

          # Add previously removed fees to the contribution settlement details
          results += fees if type == PublisherStatementGetter::Statement::CONTRIBUTION_SETTLEMENT

          results = results.each do |x|
            # All settlements are negative, so we should take the absolute value
            # and display it as a positive value
            x.amount = x.amount.abs unless x.transaction_type == "fees"

            total_amount += x.amount
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
        self
      end
    end
  end
end

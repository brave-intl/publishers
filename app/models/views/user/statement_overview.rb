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
                    :currency, :details, :settled_transactions, :raw_transactions, :name, :email, :total_fees, :bat_total_deposited,
                    :publisher_id, :settlement_destination

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
        @payment_date ||= brave_settled_date
        @earning_period ||= {
          start_date: settled_transactions.first.earning_period,
          end_date: brave_settled_date,
        }
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
        # settled_transactions is a list of all the transactions in a particular time period
        # Input:
        # [
        #   { "channel"=>"website.com", "transaction_type"=>"contribution_settlement", "amount"=>"-295.2125", "settlement_currency"=>"BAT", "settlement_amount"=>"295.2125", "settlement_destination_type"=>"uphold", "created_at"=>"2020-03-09" },
        #   { "channel"=>"youtube#channel", "transaction_type"=>"fees", "amount"=>"-43.8125", "settlement_currency"=>nil, "settlement_amount"=>nil, "settlement_destination_type"=>nil, "created_at"=>"2020-03-09" },
        #   { "channel"=>"youtube#channel", "transaction_type"=>"contribution_settlement", "amount"=>"-832.4375", "settlement_currency"=>"BAT", "settlement_amount"=>"832.4375", "created_at"=>"2020-03-09" },
        #   { "channel"=>"Publisher Account", "transaction_type"=>"referral_settlement", "amount"=>"-2823.755758781595223324", "settlement_currency"=>"BAT", "settlement_amount"=>"2823.755758781595223324", "created_at"=>"2020-03-09" },
        #   { "channel"=>"website.com", "transaction_type"=>"fees", "amount"=>"-15.5375", "settlement_currency"=>nil, "settlement_amount"=>nil, "settlement_destination_type"=>nil, "created_at"=>"2020-03-09" }
        # ]
        #
        # Output:
        # {
        #   "contribution_settlement"=>
        #     [
        #       {"channel"=>"website.com", "transaction_type"=>"contribution_settlement", "amount"=>"-295.2125", "settlement_currency"=>"BAT", "settlement_amount"=>"295.2125", "settlement_destination_type"=>"uphold", "created_at"=>"2020-03-09"},
        #       {"channel"=>"youtube#channel", "transaction_type"=>"contribution_settlement", "amount"=>"-832.4375", "settlement_currency"=>"BAT", "settlement_amount"=>"832.4375", "settlement_destination_type"=>"uphold", "created_at"=>"2020-03-09"}
        #     ],
        #   "fees"=>
        #     [
        #       {"channel"=>"youtube#channel", "transaction_type"=>"fees", "amount"=>"-43.8125", "settlement_currency"=>nil, "settlement_amount"=>nil, "settlement_destination_type"=>nil, "settlement_destination"=>nil, "created_at"=>"2020-03-09"},
        #       {"channel"=>"website.com", "transaction_type"=>"fees", "amount"=>"-15.5375", "settlement_currency"=>nil, "settlement_amount"=>nil, "settlement_destination_type"=>nil, "settlement_destination"=>nil, "created_at"=>"2020-03-09"}
        #     ],
        #   "referral_settlement"=>
        #     [
        #       {"channel"=>"Publisher Account","transaction_type"=>"referral_settlement", "amount"=>"-2823.755758781595223324", "settlement_currency"=>"BAT", "settlement_amount"=>"2823.755758781595223324", "settlement_destination_type"=>"uphold", "created_at"=>"2020-03-09" }
        #     ]
        # }
        grouped_transactions = settled_transactions.group_by { |x| x.transaction_type }

        # Fees are only associated with Contribution Settlement, so let's group the fees explicitly with contributions.
        fees = grouped_transactions.delete("fees")

        grouped_transactions.each do |type, results|
          total_amount = 0

          if type == PublisherStatementGetter::Statement::CONTRIBUTION_SETTLEMENT
            # On contribution_settlement transactions the fees are subtracted automatically from the settlement.
            # If we want to display the correct amount under "Total" we must add back in the fees to the main transaction
            # We group by channel, there is a pairing of contribution_settlement and fees
            results.group_by(&:channel).each do |name, channels|
              # If there are multiple payouts within a month we go through each
              channel_fees = fees.select { |x| x.channel == name }
              channels.each_with_index do |settlement, index|
                # Since the transactions are sorted we should be able to use the same index as the contribution settlement
                # For every contribution_settlement there will always be an associated fee transaction type
                # binding.pry if channel_fees[index].blank?
                settlement.amount += channel_fees[index].amount
              end
            end
            # Add previously removed fees to the contribution settlement details
            # Because we group_by the transaction_type fees only get added once to the results
            results += fees
          end

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

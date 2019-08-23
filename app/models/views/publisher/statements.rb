module Views
  module Publisher
    class Statements
      include ActiveModel::Model
      # include PromosHelper
      # include PublishersHelper

      attr_accessor :earning_period, :payment_date, :destination, :amount, :deposited, :currency

      def as_json(*)
        {
          earning_period: earning_period,
          payment_date: payment_date,
          destination: destination,
          amount: amount,
          deposited: deposited,
          currency: currency
        }
      end
    end
  end
end

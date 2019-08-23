module Views
  module User
    class StatementOverview
      include ActiveModel::Model
      # include PromosHelper
      # include PublishersHelper

      attr_accessor :earning_period, :payment_date, :destination, :amount, :deposited, :currency, :details, :raw, :name, :email

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
    end
  end
end

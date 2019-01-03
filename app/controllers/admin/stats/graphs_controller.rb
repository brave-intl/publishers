module Admin
  module Stats
    class GraphsController < AdminController
      START_DATE = '2018-05-01'.freeze

      def index
        @publisher_stats = []

        current_date = START_DATE.to_date
        while current_date < Date.today
          current_date = current_date.beginning_of_month
          count = Publisher
            .email_verified
            .joins(:channels)
            .where(
              'channels.verified = true AND (verified_at <= ? OR verified_at IS NULL)',
              current_date
            ).distinct.count


          @publisher_stats << { label: current_date.strftime('%y-%m-%d'), value: count }

          current_date = current_date.next_month
        end

      end
    end
  end
end

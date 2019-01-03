require "csv"

module Admin
  module Stats
    class PublisherStatisticsController < AdminController
      START_DATE = "2018-05-01".freeze

      def index
        @all_publishers = stats[:all_publishers]
        @email_verified = stats[:email_verified]
        @email_verified_with_channel = stats[:email_verified_with_channel]
        @email_verified_with_verified_channel = stats[:email_verified_with_verified_channel]

        respond_to do |format|
          format.html {}
          format.csv do
            report_csv = CSV.generate do |csv|
              csv << ["Month", "All Publishers", "Email Verified", "Email Verified With Channel", "Email Verified With Verified Channel"]
              @all_publishers.each_with_index do |x, i|
                csv << [x[:label], @all_publishers[i][:value], @email_verified[i][:value], @email_verified_with_channel[i][:value], @email_verified_with_verified_channel[i][:value]]
              end
            end

            send_data report_csv, filename: "Publisher Statistics #{Date.today}.csv"
          end
        end
      end

      private

      def stats
        all_publishers = []
        email_verified = []
        email_verified_with_channel = []
        email_verified_with_verified_channel = []

        current_date = START_DATE.to_date
        while current_date < Date.today
          current_date = current_date.beginning_of_month
          all_pub_count =
            Publisher.where(role: Publisher::PUBLISHER).distinct(:id).where("created_at < ?", current_date).where("pending_email is not null or email is not null").count
          verified_email =
            Publisher.where(role: Publisher::PUBLISHER).email_verified.where("created_at < ?", current_date).distinct(:id).count
          verified_with_channel =
            Publisher.where(role: Publisher::PUBLISHER).email_verified.joins(:channels).where("(channels.verified_at is null or channels.verified_at < ?) and channels.created_at < ?", current_date, current_date).distinct(:id).count
          verified_with_verified_channel_count =
            Publisher.where(role: Publisher::PUBLISHER).email_verified.joins(:channels).where(channels: { verified: true}).where("(channels.verified_at is null or channels.verified_at < ?) and channels.created_at < ?", current_date, current_date).distinct(:id).count

          all_publishers << { label: current_date.strftime("%Y-%m-%d"), value: all_pub_count }
          email_verified << { label: current_date.strftime("%Y-%m-%d"), value: verified_email }
          email_verified_with_channel << { label: current_date.strftime("%Y-%m-%d"), value: verified_with_channel }
          email_verified_with_verified_channel << { label: current_date.strftime("%Y-%m-%d"), value: verified_with_verified_channel_count }

          current_date = current_date.next_month
        end

        {
          all_publishers: all_publishers,
          email_verified: email_verified,
          email_verified_with_channel: email_verified_with_channel,
          email_verified_with_verified_channel: email_verified_with_verified_channel
        }
      end
    end
  end
end

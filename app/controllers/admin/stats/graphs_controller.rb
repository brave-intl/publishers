module Admin
  module Stats
    class GraphsController < AdminController
      def index
        # TODO Write partition statements using postgres window functions
        @youtube_stats = YoutubeChannelDetails.group("date_trunc('day', created_at)").count.to_a
        @youtube_stats = @youtube_stats.sort_by { |a| a[0] }

        @youtube_stats = @youtube_stats.map { |x| { label: x[0].strftime('%y-%m-%d'), value: x[1] } }
      end
    end
  end
end

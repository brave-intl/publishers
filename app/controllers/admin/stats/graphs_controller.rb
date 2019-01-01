module Admin
  module Stats
    class GraphsController < AdminController
      def index
        @youtube_stats = YoutubeChannelDetails.group("date_trunc('day', created_at)").count
        @youtube_stats.to_a.map! { |x| { label: x[0], value: x[1] } }

      end
    end
  end
end

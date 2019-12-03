class Admin::Stats::TopYoutubeChannelsController < AdminController
  def index
    @youtube_channel_details = YoutubeChannelDetails.joins(:channel).where.not(stats: "{}").order("stats->'subscriber_count' DESC").limit(400)
  end
end

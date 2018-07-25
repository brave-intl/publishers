module ChannelStatsServices
  class YoutubeChannelStatsService < BaseApiClient
    
    def initialize(youtube_channel_details:)
      @channel_details = youtube_channel_details
    end

    def perform
      return perform_offline if Rails.application.secrets[:api_twitch_base_uri].blank? # Currently using twitch api as a proxy
      response = Yt::Channel.new id: @channel_details.youtube_channel_id
            
      stats = {
        "video_count": response.video_count,
        "view_count": response.view_count,
        "subscriber_count": response.subscriber_count,
        "comment_count": response.comment_count        
      }

      @channel_details.stats = stats
      @channel_details.save!
    end

    def perform_offline
      true
    end
  end
end
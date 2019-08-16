class Admin::Stats::ContributionsController < AdminController
  def index
    @result = Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_CONTRIBUTION_TOTALS) || []
    @publishers = Publisher.where(id: @result.map { |entry| entry['account_id'].split(":")[1] }).load
    @youtube_channel_details = YoutubeChannelDetails
      .where(youtube_channel_id:
             @result.select { |entry| entry['channel'].starts_with?(YoutubeChannelDetails::YOUTUBE_PREFIX) }
                    .map{ |entry| entry['channel'].remove(YoutubeChannelDetails::YOUTUBE_PREFIX) }
      ).load
  end
end

class Admin::Stats::ReferralsController < AdminController
  def index
    @result = Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_REFERRAL_TOTALS) || []
    @publishers = Publisher.where(id: @result.map { |entry| entry['account_id'].split(":")[1] }).load
    @youtube_channel_details = YoutubeChannelDetails
      .where(youtube_channel_id:
             @result.select { |entry| entry['channel'].starts_with?(YoutubeChannelDetails::PREFIX) }
                    .map{ |entry| entry['channel'].remove(YoutubeChannelDetails::PREFIX) }
      ).load
  end
end

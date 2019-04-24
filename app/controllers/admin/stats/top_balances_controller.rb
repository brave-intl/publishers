class Admin::Stats::TopBalancesController < AdminController
  def index
    @limit = params[:limit].present? ? params[:limit].to_i : 25
    @result = JSON.parse(case params[:type]
    when Eyeshade::TopBalances::CHANNEL
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_CHANNEL_BALANCES) || "[]"
    when Eyeshade::TopBalances::OWNER
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_PUBLISHER_BALANCES) || "[]"
    when Eyeshade::TopBalances::UPHOLD
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_UPHOLD_BALANCES) || "[]"
    end)
    if @result.present?
      @result = @result.take(@limit)
    end

    if params[:type] == Eyeshade::TopBalances::CHANNEL
      @table_identifier = "youtube#channel"
      @youtube_channels = YoutubeChannelDetails
                            .joins(:channel)
                            .where(channels: { verified: true })
                            .where(youtube_channel_id:
                              @result.select { |entry| entry["account_id"].split(":")[0] == @table_identifier }
                              .map { |entry| entry["account_id"].split(":")[1]}
                            )
                              .pluck("youtube_channel_id, channels.publisher_id, title")
                            .map { |row| {row[0] => [row[1], row[2]]}}
                            .reduce(:merge)
      @site_channels = SiteChannelDetails
                          .joins(:channel)
                          .where(channels: { verified: true })
                          .where(brave_publisher_id:
                              @result.map { |entry| entry["account_id"] }
                          )
                          .pluck("brave_publisher_id, channels.publisher_id")
                          .to_h
    elsif params[:type] == Eyeshade::TopBalances::OWNER
      @publisher_emails = Publisher.where(id: @result.map { |entry| entry["account_id"].split(":")[1] }).pluck(:id, :email).to_h
    end

    @type = params[:type]
  end
end

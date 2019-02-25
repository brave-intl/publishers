class Admin::Stats::TopBalancesController < AdminController
  def index
    @limit = params[:limit].present? ? params[:limit].to_i : 25
    @result = JSON.parse(case params[:type]
    when Eyeshade::TopBalances::CHANNEL
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_CHANNEL_BALANCES) || []
    when Eyeshade::TopBalances::OWNER
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_PUBLISHER_BALANCES) || []
    when Eyeshade::TopBalances::UPHOLD
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_UPHOLD_BALANCES) || []
    end)
    if @result.present?
      @result = @result.take(@limit)
    end
    @type = params[:type]
  end
end

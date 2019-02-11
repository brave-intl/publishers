class Admin::Stats::TopBalancesController < AdminController
  def index
    @result = case params[:type]
    when Eyeshade::TopBalances::CHANNEL
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_CHANNEL_BALANCES) || []
    when Eyeshade::TopBalances::OWNER
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_PUBLISHER_BALANCES) || []
    when Eyeshade::TopBalances::UPHOLD
      Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_TOP_UPHOLD_BALANCES) || []
    end
  end
end

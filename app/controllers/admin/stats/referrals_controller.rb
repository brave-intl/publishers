class Admin::Stats::ReferralsController < AdminController
  def index
    @result = Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_REFERRAL_TOTALS) || []
  end
end

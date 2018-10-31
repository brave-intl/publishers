class Admin::Stats::ContributionsController < AdminController
  def index
    @result = Rails.cache.fetch(Cache::EyeshadeStatsJob::EYESHADE_CONTRIBUTION_TOTALS) || []
  end
end

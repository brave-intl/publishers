class Cache::EyeshadeStatsJob < ApplicationJob
  queue_as :transactional

  EYESHADE_CONTRIBUTION_TOTALS = "eyeshade_contribution_totals".freeze
  EYESHADE_REFERRAL_TOTALS = "eyeshade_referral_totals".freeze

  def perform
    Rails.cache.write(EYESHADE_CONTRIBUTION_TOTALS, Eyeshade::ContributionTotals.new.perform)
    Rails.cache.write(EYESHADE_REFERRAL_TOTALS, Eyeshade::ReferralTotals.new.perform)
  end
end

class Cache::EyeshadeStatsJob < ApplicationJob
  queue_as :transactional

  EYESHADE_CONTRIBUTION_TOTALS = "eyeshade_contribution_totals".freeze
  EYESHADE_REFERRAL_TOTALS = "eyeshade_referral_totals".freeze
  EYESHADE_TOP_CHANNEL_BALANCES = "eyeshade_top_channel_balances".freeze
  EYESHADE_TOP_PUBLISHER_BALANCES = "eyeshade_top_owner_balances".freeze
  EYESHADE_TOP_UPHOLD_BALANCES = "eyeshade_top_uphold_balances".freeze

  def perform
    Rails.cache.write(EYESHADE_CONTRIBUTION_TOTALS, Eyeshade::ContributionTotals.new.perform)
    Rails.cache.write(EYESHADE_REFERRAL_TOTALS, Eyeshade::ReferralTotals.new.perform)
    Rails.cache.write(EYESHADE_TOP_CHANNEL_BALANCES, Eyeshade::TopBalances.new(type: Eyeshade::TopBalances::CHANNEL).perform)
    Rails.cache.write(EYESHADE_TOP_PUBLISHER_BALANCES, Eyeshade::TopBalances.new(type: Eyeshade::TopBalances::OWNER).perform)
    Rails.cache.write(EYESHADE_TOP_UPHOLD_BALANCES, Eyeshade::TopBalances.new(type: Eyeshade::TopBalances::UPHOLD).perform)
  end
end

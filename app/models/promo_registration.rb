class PromoRegistration < ApplicationRecord
  has_paper_trail

  # A promo registration can belong to a channel,
  # a publisher, or be unattached.  Unattached codes
  # are created by admins.

  # Constants
  CHANNEL = "channel".freeze
  OWNER = "owner".freeze
  UNATTACHED ="unattached".freeze
  KINDS = [CHANNEL, OWNER, UNATTACHED].freeze

  RETRIEVALS = "retrievals" # Aliased as 'Downloads'
  FIRST_RUNS = "first_runs" # Aliased as 'Installs'
  FINALIZED = "finalized" # Aliased as 'Confirmed'

  DAILY = "daily"
  WEEKLY = "weekly"
  MONTHLY = "monthly"
  RUNNING_TOTAL = "running_total"
  
  belongs_to :channel, validate: true, autosave: true
  belongs_to :promo_campaign

  validates :channel_id, presence: true, if: -> { kind == CHANNEL}
  validates :promo_id, presence: true
  validates :kind, presence: true
  validates :kind, inclusion: { in: KINDS, message: "%{value} is not a valid kind of promo registration." }
  validates :referral_code, presence: true, uniqueness: { scope: :promo_id }

  scope :unattached_only, -> { where(kind: UNATTACHED) }
  scope :channels_only, -> { where(kind: CHANNEL) }

  def aggregate_stats
    JSON.parse(stats).reduce({RETRIEVALS => 0,
                              FIRST_RUNS => 0,
                              FINALIZED => 0}) { |aggregate_stats, event|
      aggregate_stats[RETRIEVALS] += event[RETRIEVALS]
      aggregate_stats[FIRST_RUNS] += event[FIRST_RUNS]
      aggregate_stats[FINALIZED] += event[FINALIZED]
      aggregate_stats.slice(RETRIEVALS, FIRST_RUNS, FINALIZED)
    }
  end
end

class PromoRegistration < ApplicationRecord
  has_paper_trail

  # A promo registration can belong to a channel,
  # a publisher, or be unattached.  Unattached codes
  # are created by admins.
  CHANNEL = "channel".freeze
  OWNER = "owner".freeze
  UNATTACHED ="unattached".freeze
  KINDS = [CHANNEL, OWNER, UNATTACHED].freeze

  # Event types
  RETRIEVALS = "retrievals" # Aliased as 'Downloads'
  FIRST_RUNS = "first_runs" # Aliased as 'Installs'
  FINALIZED = "finalized" # Aliased as 'Confirmed'

  COUNTRY = "country"

  # Reporting intervals
  DAILY = "daily"
  WEEKLY = "weekly"
  MONTHLY = "monthly"
  RUNNING_TOTAL = "running_total"

  # Installer types
  SILENT = "silent"
  MOBILE = "mobile"
  STANDARD = "standard"


  belongs_to :channel, validate: true, autosave: true
  belongs_to :promo_campaign
  belongs_to :publisher

  validates :channel_id, presence: true, if: -> { kind == CHANNEL }
  validates :publisher_id, presence: true, unless: -> { kind == UNATTACHED }

  validates :promo_id, presence: true
  validates :kind, presence: true
  validates :kind, inclusion: { in: KINDS, message: "%{value} is not a valid kind of promo registration." }
  validates :referral_code, presence: true, uniqueness: { scope: :promo_id }

  scope :owner_only, -> { where(kind: OWNER) }
  scope :unattached_only, -> { where(kind: UNATTACHED) }
  scope :channels_only, -> { where(kind: CHANNEL) }

  # Parses the events associated with a promo registration and returns
  # the aggregate totals for each event type
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

  # the stats are currently organized by platform.
  def stats_by_date
    compressed_stats = {}
    JSON.parse(stats).each do |stat|
      unless compressed_stats.has_key?(stat['ymd'])
        compressed_stats[stat['ymd']] = {}
        compressed_stats[stat['ymd']]['retrievals'] = 0
        compressed_stats[stat['ymd']]['first_runs'] = 0
        compressed_stats[stat['ymd']]['finalized'] = 0
        compressed_stats[stat['ymd']]['ymd'] = stat['ymd']
      end
      compressed_stats[stat['ymd']]['retrievals'] += stat['retrievals']
      compressed_stats[stat['ymd']]['first_runs'] += stat['first_runs']
      compressed_stats[stat['ymd']]['finalized'] += stat['finalized']
    end
    compressed_stats.values
  end

  class << self
    # Returns the aggregate totals for each event type given a
    # ActiveRecord::Association of PromoRegistrations
    def aggregate_stats(promo_registrations)
      promo_registrations.reduce({RETRIEVALS => 0,
                                  FIRST_RUNS => 0,
                                  FINALIZED => 0}) { |aggregate_stats, promo_registration|
        promo_registration_aggregate_stats = promo_registration.aggregate_stats
        aggregate_stats[RETRIEVALS] += promo_registration_aggregate_stats[RETRIEVALS]
        aggregate_stats[FIRST_RUNS] += promo_registration_aggregate_stats[FIRST_RUNS]
        aggregate_stats[FINALIZED] += promo_registration_aggregate_stats[FINALIZED]
        aggregate_stats
      }
    end
  end
end

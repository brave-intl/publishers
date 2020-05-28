class PromoRegistration < ApplicationRecord
  # A promo registration can belong to a channel,
  # a publisher, or be unattached.  Unattached codes
  # are created by admins.
  CHANNEL = "channel".freeze
  OWNER = "owner".freeze
  UNATTACHED = "unattached".freeze
  PEER_TO_PEER = "peer_to_peer".freeze
  KINDS = [CHANNEL, OWNER, UNATTACHED, PEER_TO_PEER].freeze

  # Event types
  RETRIEVALS = "retrievals".freeze # Aliased as 'Downloads'
  FIRST_RUNS = "first_runs".freeze # Aliased as 'Installs'
  FINALIZED = "finalized".freeze # Aliased as 'Confirmed'
  EYESHADE_CONFIRMED = "eyeshade_confirmed".freeze

  COUNTRY = "country".freeze
  COUNTRY_CODE = "country_code".freeze

  # Reporting intervals
  DAILY = "day".freeze
  WEEKLY = "week".freeze
  MONTHLY = "month".freeze
  RUNNING_TOTAL = "running_total".freeze

  # Installer types
  SILENT = "silent".freeze
  MOBILE = "mobile".freeze
  STANDARD = "standard".freeze

  BASE_STATS = { RETRIEVALS => 0, FIRST_RUNS => 0, FINALIZED => 0, EYESHADE_CONFIRMED => 0 }.freeze

  before_save :set_active_promo_id, if: -> { promo_id.nil? }
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
  scope :has_stats, -> { where.not(stats: "[]").where.not("stats = '[]'") }

  before_destroy :delete_from_promo_server

  def set_active_promo_id
    self.promo_id = Rails.application.secrets[:active_promo_id]
  end

  def delete_from_promo_server
    Promo::ChannelOwnerUpdater.new(referral_code: referral_code).perform
  end

  # Parses the events associated with a promo registration and returns
  # the aggregate totals for each event type
  def aggregate_stats
    aggregate_stats_by_period(Date.new, Date.tomorrow)
  end

  def aggregate_stats_by_period(period_start, period_end)
    parsed = stats.instance_of?(String) ? JSON.parse(stats) : stats
    parsed = parsed.select do |event|
      date = event['ymd'].to_date
      date >= period_start && date <= period_end
    end

    parsed.reduce(BASE_STATS.deep_dup, &PromoRegistration.sum_stats)
  end

  # the stats are currently organized by platform.
  def stats_by_date
    compressed_stats = {}
    starting_date = nil
    parsed = stats.instance_of?(String) ? JSON.parse(stats) : stats
    parsed.each do |stat|
      starting_date ||= stat['ymd'] if starting_date.nil?
      unless compressed_stats.key?(stat['ymd'])
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

    return [] if starting_date.nil?

    rolling_date = Date.parse(starting_date)
    while rolling_date < Date.today
      formatted_date = rolling_date.strftime("%Y-%m-%d")
      unless compressed_stats.key?(formatted_date)
        compressed_stats[formatted_date] = {}
        compressed_stats[formatted_date]['retrievals'] = 0
        compressed_stats[formatted_date]['first_runs'] = 0
        compressed_stats[formatted_date]['finalized'] = 0
        compressed_stats[formatted_date]['ymd'] = formatted_date
      end
      rolling_date = rolling_date.tomorrow
    end

    compressed_stats.values.sort_by! { |h| h['ymd'] }
  end

  class << self
    # Returns the aggregate totals for each event type given a
    # ActiveRecord::Association of PromoRegistrations
    def stats_for_registrations(promo_registrations:, start_date: Date.new, end_date: Date.today.at_end_of_day)
      promo_registrations.
        map { |pr| pr.aggregate_stats_by_period(start_date, end_date) }.
        reduce(PromoRegistration::BASE_STATS.deep_dup, &PromoRegistration.sum_stats)
    end

    def sum_stats
      Proc.new do |aggregate_stats, event|
        aggregate_stats.keys.each do |key|
          aggregate_stats[key] += event[key].to_i
        end

        aggregate_stats
      end
    end
  end
end

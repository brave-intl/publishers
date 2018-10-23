class PromoRegistration < ApplicationRecord
  has_paper_trail

  # A promo registration can belong to a channel,
  # a publisher, or be unattached.  Unattached codes
  # are created by admins.

  CHANNEL = "channel".freeze
  OWNER = "owner".freeze
  UNATTACHED ="unattached".freeze
  KINDS = [CHANNEL, OWNER, UNATTACHED].freeze
  
  belongs_to :channel, validate: true, autosave: true
  belongs_to :promo_campaign

  validates :channel_id, presence: true, if: -> { kind == CHANNEL}
  validates :promo_id, presence: true
  validates :kind, presence: true
  validates :kind, inclusion: { in: KINDS, message: "%{value} is not a valid kind of promo registration." }
  validates :referral_code, presence: true, uniqueness: { scope: :promo_id }

  scope :unattached, -> { where(kind: "unattached") }

  def aggregate_stats
    JSON.parse(stats).reduce({"retrievals" => 0,
                              "first_runs" => 0,
                              "finalized" => 0}) { |aggregate_stats, event|
      aggregate_stats["retrievals"] += event["retrievals"]
      aggregate_stats["first_runs"] += event["first_runs"]
      aggregate_stats["finalized"] += event["finalized"]
      aggregate_stats.slice("retrievals", "first_runs", "finalized")
    }
  end
end

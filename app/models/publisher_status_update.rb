class PublisherStatusUpdate < ApplicationRecord
  CREATED = 'created'.freeze
  ONBOARDING = 'onboarding'.freeze
  ACTIVE = 'active'.freeze
  SUSPENDED = 'suspended'.freeze
  LOCKED = 'locked'.freeze
  DELETED = 'deleted'.freeze
  NO_GRANTS = 'no_grants'.freeze
  HOLD = 'hold'.freeze
  ONLY_USER_FUNDS = 'only_user_funds'.freeze

  ALL_STATUSES = [CREATED, ONBOARDING, ACTIVE, SUSPENDED, LOCKED, NO_GRANTS, DELETED, HOLD, ONLY_USER_FUNDS].freeze

  DESCRIPTIONS = {
    CREATED => "User has signed up but not signed in.",
    ONBOARDING => "User has signed in but not completed entering their information",
    ACTIVE => "User is an active publisher. User can perform normal account operations.",
    SUSPENDED => "Account has been placed under review.",
    ONLY_USER_FUNDS => "User will not receive any Brave funds. Only funds that will be sent are user funded.",
    LOCKED => "User has removed 2-FA but still needs to wait until a month has passed to receive payout.",
    NO_GRANTS => "User can receive user funded tips and use the referral promotion system.",
    HOLD => "User's payment is held awaiting additional information and interview on how they obtained referrals and contributions.",
    DELETED => "user has been deleted from the publishers system.",
  }.freeze

  belongs_to :publisher
  belongs_to :publisher_note

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  validates :publisher_id, presence: true

  def to_s
    status
  end
end

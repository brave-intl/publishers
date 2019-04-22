class PublisherStatusUpdate < ApplicationRecord
  CREATED = 'created'.freeze
  ONBOARDING = 'onboarding'.freeze
  ACTIVE = 'active'.freeze
  SUSPENDED = 'suspended'.freeze
  LOCKED = 'locked'.freeze
  UMBRA = 'umbra'.freeze

  ALL_STATUSES = [CREATED, ONBOARDING, ACTIVE, SUSPENDED, LOCKED, UMBRA].freeze

  belongs_to :publisher

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  validates :publisher_id, presence: true

  def to_s
    status
  end
end

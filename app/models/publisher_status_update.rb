class PublisherStatusUpdate < ApplicationRecord
  SUSPENDED = 'suspended'.freeze
  ACTIVE = 'active'.freeze
  ONBOARDING = 'onboarding'.freeze
  CREATED = 'created'.freeze

  ALL_STATUSES = [CREATED, ONBOARDING, ACTIVE, SUSPENDED].freeze

  belongs_to :publisher

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  validates :publisher_id, presence: true

  def to_s
    status
  end
end

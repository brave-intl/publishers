class PublisherStatusUpdate < ApplicationRecord
  SUSPENDED = 'suspended'
  ACTIVE = 'active'
  ONBOARDING = 'onboarding'
  CREATED = 'created'

  ALL_STATUSES = [CREATED, ONBOARDING, ACTIVE, SUSPENDED]

  belongs_to :publisher

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  validates :publisher_id, presence: true
end

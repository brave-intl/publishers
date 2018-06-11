class PublisherStatusUpdate < ApplicationRecord  
  ALL_STATUSES = ["created", "onboarding", "active", "suspended"]

  belongs_to :publisher
  
  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  validates :publisher_id, presence: true
end
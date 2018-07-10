class PublisherStatement < ApplicationRecord
  has_paper_trail

  EXPIRE_AFTER = 1.day

  attr_encrypted :contents, key: :encryption_key

  belongs_to :publisher
  validates :publisher_id, presence: true
  validates :period, presence: true

  after_create :set_expiration

  scope :expired, -> { where("expires_at < :now", now: Time.zone.now) }

  scope :visible_statements, -> { where(created_by_admin: false) }

  def set_expiration
    self.expires_at = Time.zone.now + EXPIRE_AFTER
    save!
  end

  def expired?
    Time.zone.now > self.expires_at
  end

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end
end

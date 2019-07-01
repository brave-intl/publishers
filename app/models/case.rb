class Case < ApplicationRecord
  has_paper_trail

  NEW = "new".freeze
  OPEN = "open".freeze
  ASSIGNED = "assigned".freeze
  ACCEPTED = "accepted".freeze
  REJECTED = "rejected".freeze

  ALL_STATUSES = [NEW, OPEN, ACCEPTED, ASSIGNED, REJECTED].freeze

  belongs_to :assignee, class_name: "Publisher"
  belongs_to :publisher

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  has_many_attached :files

  before_save :updated_status, if: :assignee_id_changed?

  def updated_status
    if assignee_id.present?
      self.status = ASSIGNED
    else
      self.status = OPEN
    end
  end

  def new?
    status == NEW
  end

  def assigned?
    status == ASSIGNED
  end

  def rejected?
    status == REJECTED
  end

  def open?
    status == OPEN
  end
end

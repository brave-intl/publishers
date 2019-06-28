class Case < ApplicationRecord
  has_paper_trail

  NEW = "new"
  OPEN = "open"
  ACCEPTED = "accepted"
  REJECTED = "rejected"

  ALL_STATUSES = [NEW, OPEN, ACCEPTED, REJECTED]

  belongs_to :assignee, class_name: "Publisher"
  belongs_to :publisher

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  def new?
    status == NEW
  end

  def open?
    status == OPEN
  end
end

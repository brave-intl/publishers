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
  after_save :send_out_emails, if: :saved_change_to_status?

  def updated_status
    if assignee_id.present? && self.status == OPEN
      self.status = ASSIGNED
    end
  end

  def send_out_emails
    case self.status
    when OPEN
      PublisherMailer.submit_appeal(self.publisher).deliver_later
    when ACCEPTED
      PublisherMailer.accept_appeal(self.publisher).deliver_later
    when REJECTED
      PublisherMailer.reject_appeal(self.publisher).deliver_later
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

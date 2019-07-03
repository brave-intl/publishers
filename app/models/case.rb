class Case < ApplicationRecord
  has_paper_trail ignore: [:solicit_question, :accident_question]

  NEW = "new".freeze
  OPEN = "open".freeze
  ASSIGNED = "assigned".freeze
  ACCEPTED = "accepted".freeze
  REJECTED = "rejected".freeze

  ALL_STATUSES = [NEW, OPEN, ACCEPTED, ASSIGNED, REJECTED].freeze
  FILE_SIZE = 2.megabyte

  belongs_to :assignee, class_name: "Publisher"
  belongs_to :publisher

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  has_many_attached :files

  before_save :updated_status, if: :assignee_id_changed?
  after_save :send_out_emails, if: :saved_change_to_status?

  validate :file_attachment_validation

  def file_attachment_validation
    files.each do |file|
      if file.blob.byte_size > FILE_SIZE
        file.purge
        errors[:base] << "File #{file.blob.filename} must be less than 2 MB"
      end
    end
  end

  def updated_status
    if assignee_id.present? && status == OPEN
      self.status = ASSIGNED
    end
  end

  def send_out_emails
    case status
    when OPEN
      PublisherMailer.submit_appeal(publisher).deliver_later
    when ACCEPTED
      PublisherMailer.accept_appeal(publisher).deliver_later
    when REJECTED
      PublisherMailer.reject_appeal(publisher).deliver_later
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

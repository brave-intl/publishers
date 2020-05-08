# frozen_string_literal: true

class Case < ApplicationRecord
  has_paper_trail ignore: [:solicit_question, :accident_question]

  self.per_page = 50

  NEW = "new"
  OPEN = "open"
  IN_PROGRESS = "in_progress"
  RESOLVED = "resolved"
  CLOSED = "closed"

  ALL_STATUSES = [NEW, OPEN, RESOLVED, IN_PROGRESS, CLOSED].freeze

  FILE_SIZE = 2.megabyte
  FILE_TYPES = [
    "application/vnd",
    "image",
    "application/pdf",
    "application/msword",
  ].freeze

  belongs_to :assignee, class_name: "Publisher"
  belongs_to :publisher

  has_many :case_notes

  validates :status, presence: true, :inclusion => { in: ALL_STATUSES }

  has_many_attached :files

  before_save :updated_status, if: :assignee_id_changed?
  before_save :add_open_at, if: Proc.new { |_| will_save_change_to_status?(from: NEW) }

  after_save :send_out_emails, if: :saved_change_to_status?

  validate :file_attachment_validation

  def file_attachment_validation
    files.each do |file|
      if file.blob.byte_size > FILE_SIZE
        errors[:base] << "File #{file.blob.filename} must be less than 2 MB"
      elsif file.present? && invalid_file_type?(file)
        errors[:base] << "#{file.blob.content_type} is not a supported filetype"
      end
    end
  end

  def invalid_file_type?(file)
    valid = Case::FILE_TYPES.any? do |type|
      file.blob.content_type.starts_with?(type)
    end

    !valid
  end

  def add_open_at
    self.open_at = DateTime.now
  end

  def updated_status
    if assignee_id.present? && status == OPEN
      self.status = IN_PROGRESS
    elsif assignee_id.blank?
      self.status = OPEN
    end
  end

  def send_out_emails
    case status
    when OPEN
      PublisherMailer.submit_appeal(publisher).deliver_later
    when RESOLVED
      PublisherMailer.accept_appeal(publisher).deliver_later
    when CLOSED
      PublisherMailer.reject_appeal(publisher).deliver_later
    end
  end

  def new?
    status == NEW
  end

  def in_progress?
    status == IN_PROGRESS
  end

  def resolved?
    status == RESOLVED
  end

  def closed?
    status == CLOSED
  end

  def open?
    status == OPEN
  end

  def answered?
    @answered ||= case_notes.where(public: true).order(created_at: :asc).last&.created_by&.admin?
  end

  def number
    case_number.to_s.rjust(5, "0")
  end
end

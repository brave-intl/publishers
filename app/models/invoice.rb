# frozen_string_literal: true

class Invoice < ActiveRecord::Base
  class ReadOnlyError < StandardError; end

  belongs_to :partner

  belongs_to :uploaded_by, class_name: "Publisher"
  belongs_to :paid_by, class_name: "Publisher"
  belongs_to :finalized_by, class_name: "Publisher"

  has_many :invoice_files, -> { order(created_at: :desc) }

  URL_DATE_FORMAT = "%Y-%m"

  IN_PROGRESS = "in progress"
  PENDING = "pending"
  PAID = "paid"

  STATUS_FIELDS = [PENDING, PAID, IN_PROGRESS].freeze

  validates :partner_id, :date, presence: true
  validates :status, inclusion: { in: STATUS_FIELDS }

  validates :date, uniqueness: { scope: :partner_id }

  def human_date
    if date.utc.day == 1
      date.utc.strftime("%B %Y")
    else
      date.utc.strftime("%B %d, %Y")
    end
  end

  def in_progress?
    status == IN_PROGRESS
  end

  def pending?
    status == PENDING
  end

  def as_json(_options = {})
    {
      id: id,
      amount: amount,
      status: status.titleize,
      date: human_date,
      url: Rails.application.routes.url_helpers.partners_payments_invoice_path(date.in_time_zone("UTC").strftime(URL_DATE_FORMAT)),
      files: invoice_files.where(archived: false).as_json.compact,
      paid: paid,
      payment_date: payment_date,
      finalized_amount: finalized_amount,
      created_at: created_at.strftime("%b %d, %Y")
    }
  end
end

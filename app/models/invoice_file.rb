class InvoiceFile < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :uploaded_by, class_name: "Publisher"

  has_one_attached :file

  validates :file, presence: true

  def active_files
    self.invoice.invoice_files.where(archived: false)
  end

  def as_json(options={})
    return unless self.file.attached?
    {
      id: self.id,
      file: {
        name: self.file.filename,
        url: Rails.application.routes.url_helpers.rails_blob_path(self.file, disposition: "attachment", only_path: true),
      },
      can_archive: self.uploaded_by.partner? && self.invoice.pending?,
      archived: self.archived,
      url: Rails.application.routes.url_helpers.partners_payments_invoice_invoice_file_url(invoice_id: '_', id: self.id, only_path: true),
      uploaded_by: self.uploaded_by.name,
      created_at: self.created_at.strftime("%b %d, %Y")
    }
  end
end

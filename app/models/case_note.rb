class CaseNote < ApplicationRecord
  FILE_SIZE = 2.megabyte

  belongs_to :case
  belongs_to :created_by, class_name: "Publisher"

  validates :created_by, presence: true
  validates :note, presence: true, allow_blank: false

  has_many_attached :files


  validate :file_attachment_validation

  def file_attachment_validation
    files.each do |file|
      if file.blob.byte_size > FILE_SIZE
        file.purge
        errors[:base] << "File #{file.blob.filename} must be less than 2 MB"
      end
    end
  end
end

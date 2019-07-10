# frozen_string_literal: true

class CaseNote < ApplicationRecord
  belongs_to :case
  belongs_to :created_by, class_name: "Publisher"

  validates :created_by, presence: true
  validates :note, presence: true, allow_blank: false

  has_many_attached :files

  validate :file_attachment_validation

  def file_attachment_validation
    files.each do |file|
      if file.blob.byte_size > Case::FILE_SIZE
        file.purge
        errors[:base] << "File #{file.blob.filename} must be less than 2 MB"
      elsif invalid_file_type?(file)
        file.purge
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
end

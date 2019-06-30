class CaseNote < ApplicationRecord
  belongs_to :case
  belongs_to :created_by, class_name: "Publisher"

  validates :created_by, presence: true
  validates :note, presence: true, allow_blank: false

  has_many_attached :files
end

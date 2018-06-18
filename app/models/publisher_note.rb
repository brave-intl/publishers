class PublisherNote < ApplicationRecord
  belongs_to :publisher
  belongs_to :created_by, class_name: "Publisher", foreign_key: :created_by_id
  validates :created_by, presence: true
end

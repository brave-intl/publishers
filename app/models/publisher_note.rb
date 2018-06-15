class PublisherNote < ApplicationRecord
  belongs_to :publisher
  validates :created_by, presence: true
end

# typed: true

class PublisherNote < ApplicationRecord
  belongs_to :publisher
  belongs_to :created_by, class_name: "Publisher", foreign_key: :created_by_id
  validates :created_by, presence: true

  # Enable self-references, which allows threading
  belongs_to :thread, class_name: "PublisherNote"
  has_many :comments, class_name: "PublisherNote", foreign_key: "thread_id"

  validates :note, presence: true, allow_blank: false

  UNKNOWN_PUBLISHER_ID = "00000000-0000-0000-0000-000000000000".freeze
end

class PublisherNote < ApplicationRecord
  belongs_to :publisher
  belongs_to :created_by, class_name: "Publisher", foreign_key: :created_by_id
  validates :created_by, presence: true

  def publisher_status
    PublisherStatusUpdate.where(publisher_id: publisher.id)
    .where("created_at <= ?", self.created_at)
    .order("created_at DESC")
    .first
  end
end

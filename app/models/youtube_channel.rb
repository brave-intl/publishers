class YoutubeChannel < ApplicationRecord

  has_one :publisher

  #ToDo: Do we want this?
  # has_paper_trail

  validates :title, presence: true
  validates :thumbnail_url, presence: true

  def channel_identifier
    "youtube#channel:#{id}"
  end

  def self.assign_or_new(attributes)
    obj = first || new
    obj.assign_attributes(attributes)
    obj
  end
end

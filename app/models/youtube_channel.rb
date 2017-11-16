class YoutubeChannel < ApplicationRecord
  #ToDo: paper_trail does not support string ids out of the box - more investigation needed
  # has_paper_trail

  has_one :publisher

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

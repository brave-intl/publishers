class YoutubeChannel < ApplicationRecord

  #ToDo: Do we want this?
  # has_paper_trail

  validates :title, presence: true
  validates :thumbnail_url, presence: true

  def channel_identifier
    "youtube#channel:#{id}"
  end
end

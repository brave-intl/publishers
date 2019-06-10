class RedditChannelDetails < BaseChannelDetails
  has_paper_trail

  REDDIT_PREFIX = "reddit#channel:".freeze

  validates :reddit_channel_id, presence: true
  validates :thumbnail_url, presence: true
  validates :name, presence: true
  validates :channel_url, presence: true

  def channel_identifier
    "#{REDDIT_PREFIX}#{reddit_channel_id}"
  end

  def authorizer_name
    name
  end
  ## End methods to satisfy the Eyeshade integration

  def publication_title
    nickname
  end

  def url
    channel_url
  end
end

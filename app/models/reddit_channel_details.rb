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

  def omniauth_url
    "https://ssl.reddit.com/api/v1/authorize?client_id=#{Rails.application.secrets[:reddit_client_id]}&redirect_uri=#{Rails.application.secrets[:reddit_redirect_uri]}&response_type=code&state=e501de44588f67a74302dec4f0f7f3502cac49e40e05b82d"
  end

  def authorizer_name
    name
  end
  ## End methods to satisfy the Eyeshade integration

  def publication_title
    name
  end

  def url
    channel_url
  end
  end

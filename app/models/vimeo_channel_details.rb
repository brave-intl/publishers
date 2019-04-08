class VimeoChannelDetails < BaseChannelDetails
  has_paper_trail

  VIMEO_PREFIX = "vimeo#channel:".freeze

  validates :vimeo_channel_id, presence: true
  validates :thumbnail_url, presence: true
  validates :name, presence: true
  validates :channel_url, presence: true

  def channel_identifier
    "#{VIMEO_PREFIX}#{vimeo_channel_id}"
  end

  def omniauth_url
    "https://api.vimeo.com/oauth/authorize?response_type=code&client_id=7ca223a095b8d2b2aecb9d1317b5af7b5c4c70f3&redirect_uri=https://localhost:3000/publishers/home&state=1"
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

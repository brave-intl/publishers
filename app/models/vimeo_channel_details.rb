class VimeoChannelDetails < BaseChannelDetails
  has_paper_trail

  PREFIX = "vimeo#channel:".freeze

  validates :vimeo_channel_id, presence: true
  validates :thumbnail_url, presence: true
  validates :name, presence: true
  validates :channel_url, presence: true

  def channel_identifier
    "#{PREFIX}#{vimeo_channel_id}"
  end

  def omniauth_url
    "https://api.vimeo.com/oauth/authorize?response_type=code&client_id=#{Rails.application.secrets[:vimeo_client_id]}&redirect_uri=#{Rails.application.secrets[:vimeo_redirect_uri]}/publishers/home&state=1"
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

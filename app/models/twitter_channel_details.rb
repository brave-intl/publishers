class TwitterChannelDetails < BaseChannelDetails
  has_paper_trail

  validate :twitter_channel_not_changed_once_initialized
  validates :twitter_channel_id, presence: true
  validates :thumbnail_url, presence: true
  validates :name, presence: true
  validates :screen_name, presence: true


  # TODO: Figure out why eyeshade needs the email and name
  ## Begin methods to satisfy the Eyeshade integration
  def channel_identifier
    "twitter#channel:#{twitter_channel_id}"
  end

  def authorizer_email
    auth_email
  end

  def authorizer_name
    name
  end
  ## End methods to satisfy the Eyeshade integration

  def publication_title
    name
  end

  def url
    "https://twitter.com/#{screen_name}"
  end

  private

  # verification to ensure twitter_channel is not changed
  def twitter_channel_not_changed_once_initialized
    return if twitter_channel_id_was.nil?

    if twitter_channel_id_was != twitter_channel_id
      errors.add(:twitter_channel_id, "can not change once initialized")
    end
  end
end

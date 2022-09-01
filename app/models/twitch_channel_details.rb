# typed: false

class TwitchChannelDetails < BaseChannelDetails
  validate :twitch_channel_not_changed_once_initialized
  validates :twitch_channel_id, presence: true
  validates :thumbnail_url, presence: true
  validates :auth_user_id, presence: true
  validates :display_name, presence: true

  PREFIX = "twitch#author:".freeze

  ## Begin methods to satisfy the Eyeshade integration

  def channel_identifier
    "#{PREFIX}#{name}"
  end

  def authorizer_email
    email
  end

  def authorizer_name
    display_name
  end

  ## End methods to satisfy the Eyeshade integration

  def publication_title
    display_name
  end

  def url
    "https://twitch.tv/#{name}"
  end

  private

  # verification to ensure twitch_channel is not changed
  def twitch_channel_not_changed_once_initialized
    return if twitch_channel_id_was.nil?

    if twitch_channel_id_was != twitch_channel_id
      errors.add(:twitch_channel_id, "can not change once initialized")
    end
  end
end

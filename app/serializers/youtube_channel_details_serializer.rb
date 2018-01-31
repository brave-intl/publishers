class YoutubeChannelDetailsSerializer < BaseChannelDetailsSerializer

  attributes :youtube_channel_id, :auth_provider, :auth_user_id, :auth_email, :auth_name, :title, :description,
             :thumbnail_url, :subscriber_count

  def method
    object.auth_provider
  end
end

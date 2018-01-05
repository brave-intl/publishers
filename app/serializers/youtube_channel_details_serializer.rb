class YoutubeChannelDetailsSerializer < ActiveModel::Serializer
  attributes :id, :youtube_channel_id, :auth_provider, :auth_user_id, :auth_email, :auth_name, :title, :description,
             :thumbnail_url, :subscriber_count, :created_at, :updated_at

  has_one :channel
end

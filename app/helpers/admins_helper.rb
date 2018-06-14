module AdminsHelper
  def channel_url(channel)
    if channel.details.is_a?(YoutubeChannelDetails)
      "https://youtube.com/channel/" + channel.details.youtube_channel_id
    elsif channel.details.is_a?(TwitchChannelDetails)
      "https://twitch.tv/" + channel.details.name
    elsif channel.details.is_a?(SiteChannelDetails)
      "https://" + channel.details.brave_publisher_id
    else
      raise "Unsupported channel type"
    end
  end
end 
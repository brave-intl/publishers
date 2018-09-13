class Api::V1::Stats::ChannelsController < Api::BaseController

def channels
  channels = Channel.all.map { |channel| channel.id }
  data = JSON.pretty_generate(channels)

  render(json: data)

end

def channels_uuid

  channel = Channel.find_by_id(params[:uuid])

  case channel.details_type
  when "SiteChannelDetails"
    channel_details = SiteChannelDetails.find_by_id(channel.details_id)
    platform = "Site"
    channel_id = channel_details.brave_publisher_id
  when "YoutubeChannelDetails"
    channel_details = YoutubeChannelDetails.find_by_id(channel.details_id)
    platform = "Youtube"
    channel_id = channel_details.youtube_channel_id
  when "TwitterChannelDetails"
    channel_details = TwitterChannelDetails.find_by_id(channel.details_id)
    platform = "Twitter"
    channel_id = channel_details.twitter_channel_id
  when "TwitchChannelDetails"
    channel_details = TwitchChannelDetails.find_by_id(channel.details_id)
    platform = "Twitch"
    channel_id = channel_details.twitch_channel_id
  end

  data = JSON.pretty_generate({
    uuid: channel.id,
    platform: platform,
    name: channel_details.name,
    channel_id: channel_id,
    stats: channel_details.stats,
    publisher_id: channel.publisher_id,
    created_at: channel.created_at,
    verified: channel.verified
  })

  render(json: data)

end
end

class Api::V1::Stats::ChannelsController < Api::BaseController

  def channels

    if(params[:uuid] == nil)

      channels = Channel.all.map { |channel| channel.id }
      data = JSON.pretty_generate(channels)
      render(json: data)

    else

      channel = Channel.find_by_id(params[:uuid])

      if(channel == nil)
        redirect_to "/404"
      else

        case channel.details_type
          when "SiteChannelDetails"
            channel_details = SiteChannelDetails.find_by_id(channel.details_id)
            channel_type = "website"
            channel_name = channel_details.url
          when "YoutubeChannelDetails"
            channel_details = YoutubeChannelDetails.find_by_id(channel.details_id)
            channel_type = "youtube"
            channel_name = channel_details.name
          when "TwitterChannelDetails"
            channel_details = TwitterChannelDetails.find_by_id(channel.details_id)
            channel_type = "twitter"
            channel_name = channel_details.name
          when "TwitchChannelDetails"
            channel_details = TwitchChannelDetails.find_by_id(channel.details_id)
            channel_type = "twitch"
            channel_name = channel_details.name
          end

          data = JSON.pretty_generate({
            uuid: channel.id,
            channel_id: channel_details.channel_identifier,
            channel_type: channel_type,
            name: channel_name,
            stats: channel_details.stats,
            url: channel_details.url,
            owner_id: channel.publisher.owner_identifier,
            created_at: channel.created_at,
            verified: channel.verified
            })

          render(json: data)

      end
    end
  end
end

class Api::V1::Stats::ChannelsController < Api::BaseController
  def index

      channels = Channel.pluck(:id)
      data = channels.to_json
      render(status: 200, json: data) and return

  end

  def show

      channel = Channel.find(params[:channel_id])

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

      data = {
        channel_id: channel.id,
        channel_identifier: channel_details.channel_identifier,
        channel_type: channel_type,
        name: channel_name,
        stats: channel_details.stats,
        url: channel_details.url,
        owner_id: channel.publisher.owner_identifier,
        created_at: channel.created_at,
        verified: channel.verified
      }

      render(status: 200, json: data) and return

      rescue ActiveRecord::RecordNotFound
        error_response = {
          errors: [{
            status: "404",
            title: "Not Found",
            detail: "Channel with id #{params[:channel_id]} not found"
            }]
          }

      render(status: 404, json: error_response) and return

  end

end

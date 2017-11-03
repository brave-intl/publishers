class PublisherYoutubeChannelSyncer
  attr_reader :publisher

  def initialize(publisher:, token:)
    @publisher = publisher
    @token = token
  end

  def perform
    # Get the channel information. Will search for the token identified user's channel, or of it's already
    # set grab a refresh
    channel_json = YoutubeChannelGetter.new(publisher: @publisher,
                                            token: @token,
                                            channel_id: @publisher.youtube_channel_id).perform

    if channel_json.is_a?(Hash)
      channel_attrs = {
          title: channel_json.dig('snippet', 'title'),
          description: channel_json.dig('snippet', 'description'),
          thumbnail_url: channel_json.dig('snippet', 'thumbnails', 'default', 'url'),
          subscriber_count: channel_json.dig('statistics', 'subscriberCount')
      }

      # Create or update the youtube channel
      if publisher.youtube_channel
        publisher.youtube_channel.update(channel_attrs)
        :updated_channel
      else
        channel_attrs[:id] = channel_json['id']

        channel = YoutubeChannel.new(channel_attrs)
        publisher.youtube_channel = channel
        publisher.save!
        :new_channel
      end
    end

  rescue => e
    Rails.logger.warn("PublisherYoutubeChannelSyncer #perform error: #{e}\nChannel was not synced")
    raise e
  end
end

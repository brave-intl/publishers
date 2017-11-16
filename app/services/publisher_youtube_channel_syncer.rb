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
      if publisher.publication_type == :youtube_channel
        channel = publisher.youtube_channel
        # Assign attributes instead of update so we can check if things changed
        channel.assign_attributes(channel_attrs)

        changed = channel.changed?
        channel.save! if changed
      elsif publisher.publication_type == :unselected
        channel_attrs[:id] = channel_json['id']

        unless Publisher.youtube_channel_in_use(channel_attrs[:id])
          # The channel may exist, but not be associated with a publisher. In this case we'll update it
          channel = YoutubeChannel.where(id: channel_attrs[:id]).assign_or_new(channel_attrs)
          publisher.youtube_channel = channel
        else
          raise ChannelAlreadyClaimedError.new(channel_attrs[:id])
        end
        changed = true
      else
        raise InvalidPublishedTypeError.new(publisher.publication_type)
      end

      changed
    end

  rescue => e
    Rails.logger.warn("PublisherYoutubeChannelSyncer #perform error: #{e}\nChannel was not synced")
    raise e
  end

  class InvalidPublishedTypeError < RuntimeError
    def initialize(type)
      super "#{type.to_s} publisher can not sync Youtube Channel"
    end
  end

  class ChannelAlreadyClaimedError < RuntimeError
    attr_reader :channel_id

    def initialize(channel_id)
      @channel_id = channel_id
      super "Channel #{channel_id} has already been claimed"
    end
  end
end

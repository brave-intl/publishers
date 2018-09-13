# Builds a list of distinct channels that are verified for the Brave Browser.

class JsonBuilders::VerifiedChannelsJsonBuilder
  def initialize
  end

  def build
    channels = []

    [ Channel.verified.site_channels,
      Channel.youtube_channels,
      Channel.twitch_channels,
      Channel.twitter_channels].each do |verified_channels|
      verified_channels.find_each do |verified_channel|
        channels.push(verified_channel.details.channel_identifier)
      end
    end

    channels.to_json
  end
end

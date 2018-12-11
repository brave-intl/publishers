# Builds a list of distinct channels that are either verified, excluded or both for the Brave Browser.
#
# Each channel is an array:
# [
#   channel_identifier (string),
#   verified (boolean),
#   excluded (boolean),
#   site_banner details
# ]
#
# ex.
# [
#   ["brave.com", true, false, {title: 'Hello', description: 'world'...}],
#   ["google.com", false, true, {}],
#   ["us.gov", false, false, {}]
# ]

class JsonBuilders::ChannelsJsonBuilder
  def initialize
    require "publishers/excluded_channels"
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    @verified_channels = Channel.verified
    @excluded_verified_channel_ids = []
  end

  def build
    channels = []

  [Channel.verified.site_channels, Channel.youtube_channels, Channel.twitch_channels, Channel.twitter_channels].each do |verified_channels|
      verified_channels.find_each do |verified_channel|
        if @excluded_channel_ids.include?(verified_channel.details.channel_identifier)
          excluded = true
          @excluded_verified_channel_ids.push(verified_channel.details.channel_identifier)
        else
          excluded = false
        end

        # Add banners - if default_site_banner_mode=true use default_site_banner for all channels, else add channel_banner
        publisher = Publisher.find_by(id: verified_channel.publisher_id)

        if publisher
          default_site_banner_mode = publisher.default_site_banner_mode
          default_site_banner = publisher.site_banners.find_by(id: publisher.default_site_banner_id)
          channel_banner = publisher.site_banners.find_by(channel_id: verified_channel.id)
        end

        if default_site_banner_mode
          channels.push([verified_channel.details.channel_identifier, true, excluded, default_site_banner.read_only_react_property])
        elsif channel_banner
          channels.push([verified_channel.details.channel_identifier, true, excluded, channel_banner.read_only_react_property])
        else
          channels.push([verified_channel.details.channel_identifier, true, excluded, {}])
        end

      end
    end

    @excluded_channel_ids.each do |excluded_channel_id|
      next if @excluded_verified_channel_ids.include?(excluded_channel_id)
      channels.push([excluded_channel_id, false, true, {}])
    end

    channels.to_json
  end
end

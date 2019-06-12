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
    @excluded_verified_channel_ids = []
  end

  def build
    channels = []
    [
      Channel.verified.site_channels.includes(:site_banner).includes(publisher: :site_banners),
      Channel.verified.youtube_channels.includes(:site_banner).includes(publisher: :site_banners),
      Channel.verified.twitch_channels.includes(:site_banner).includes(publisher: :site_banners),
      Channel.verified.twitter_channels.includes(:site_banner).includes(publisher: :site_banners),
      Channel.verified.vimeo_channels.includes(:site_banner).includes(publisher: :site_banners),
      Channel.verified.reddit_channels.includes(:site_banner).includes(publisher: :site_banners),
      Channel.verified.github_channels.includes(:site_banner).includes(publisher: :site_banners),
    ].each do |verified_channels|
      verified_channels.find_each do |verified_channel|
        if @excluded_channel_ids.include?(verified_channel.details.channel_identifier)
          excluded = true
          @excluded_verified_channel_ids.push(verified_channel.details.channel_identifier)
        else
          excluded = false
        end
        if verified_channel.publisher.default_site_banner_mode && verified_channel.publisher.default_site_banner_id
          channels.push([verified_channel.details.channel_identifier, true, excluded, verified_channel.publisher.default_site_banner.read_only_react_property])
        elsif verified_channel.site_banner
          channels.push([verified_channel.details.channel_identifier, true, excluded, verified_channel.site_banner.read_only_react_property])
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
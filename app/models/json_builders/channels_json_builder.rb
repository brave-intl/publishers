# Builds a list of distinct channels that are either verified, excluded or both for the Brave Browser.
#
# Each channel is an array:
# [channel_identifier, verified, excluded]
#
# ex.
# [
#   ["brave.com", true, false],
#   ["google.com", false, true],
#   ["us.gov", false, false]
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

    [Channel.left_joins(publisher: :site_banner).verified.site_channels, Channel.left_joins(publisher: :site_banner).youtube_channels, Channel.left_joins(publisher: :site_banner).twitch_channels].each do |verified_channels|
      verified_channels.find_each do |verified_channel|
        if @excluded_channel_ids.include?(verified_channel.details.channel_identifier)
          excluded = true
          @excluded_verified_channel_ids.push(verified_channel.details.channel_identifier)
        else
          excluded = false
        end
        channels.push([verified_channel.details.channel_identifier, true, excluded, verified_channel.publisher&.site_banner&.read_only_react_property || {}])
      end
    end

    @excluded_channel_ids.each do |excluded_channel_id|
      next if @excluded_verified_channel_ids.include?(excluded_channel_id)
      channels.push([excluded_channel_id, false, true, {}])
    end

    channels.to_json
  end
end

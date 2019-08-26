# frozen_string_literal: true

require "publishers/excluded_channels"
# V3 Version of Channels list
#
# Each channel is an array:
# [
#   channel_identifier (string),
#   "", "connected", "verified", (string),
#   excluded (boolean),
#   wallet address
#   site_banner details
# ]
#
# ex.
# [
#   ["brave.com", "verified", false, {title: 'Hello', description: 'world'...}, 1234-abcd-5678-efgh],
#   ["google.com", false, true, {}, 1234-abcd-5678-efgh],
#   ["us.gov", false, false, {}, 1234-abcd-5678-efgh]
# ]

class JsonBuilders::ChannelsJsonBuilderV3
  UNVERIFIED = ""
  VERIFIED = "verified"
  CONNECTED = "connected"

  def initialize
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    @excluded_verified_channel_ids = Set.new
    @channels = []
  end

  def build
    joined_verified_channels.each do |verified_channels|
      verified_channels = verified_channels.
        preload(:details).
        eager_load(:uphold_connection_for_channel).
        eager_load(publisher: :uphold_connection).
        eager_load(publisher: :site_banners).
        eager_load(:site_banner).
        includes(site_banner: { logo_attachment: :blob }).
        includes(site_banner: { background_image_attachment: :blob })

      verified_channels.find_each do |verified_channel|
        include_verified_channel(verified_channel)
      end
    end
    append_excluded!
    @channels.to_json
  end

  private

  def joined_verified_channels
    [
      Channel.verified.site_channels,
      Channel.verified.youtube_channels,
      Channel.verified.twitch_channels,
      Channel.verified.twitter_channels,
      Channel.verified.vimeo_channels,
      Channel.verified.reddit_channels,
      Channel.verified.github_channels,
    ]
  end

  def include_verified_channel(verified_channel)
    identifier = verified_channel.details.channel_identifier
    in_exclusion_list = @excluded_channel_ids.include?(identifier)

    # Maintain a list of the verified sites that are excluded so we don't have to add them again
    @excluded_verified_channel_ids.add(identifier) if in_exclusion_list

    wallet_address_id = verified_channel.uphold_connection&.address

    @channels.push([
      identifier,
      status(verified_channel, wallet_address_id),
      in_exclusion_list,
      wallet_address_id || "",
      site_banner_details(verified_channel),
    ])
  end

  def status(verified_channel, address)
    connection = verified_channel.publisher&.uphold_connection

    if connection&.is_member && address.present?
      VERIFIED
    else
      CONNECTED
    end
  end

  def site_banner_details(channel)
    publisher = channel.publisher
    if publisher.default_site_banner_mode && publisher.default_site_banner_id
      publisher.default_site_banner.read_only_react_property
    elsif channel.site_banner
      channel.site_banner.read_only_react_property
    else
      {}
    end
  end

  # (Albert Wang): Note: Ordering is different from v1
  def append_excluded!
    @excluded_channel_ids.each do |excluded_channel_id|
      next if @excluded_verified_channel_ids.include?(excluded_channel_id)

      @channels.push([excluded_channel_id, UNVERIFIED, true, "", {}])
    end
  end
end

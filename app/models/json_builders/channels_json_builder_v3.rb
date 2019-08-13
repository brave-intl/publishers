# V2 Version of Channels list
#
# Each channel is an array:
# [
#   channel_identifier (string),
#   verified (boolean),
#   excluded (boolean),
#   wallet address
#   site_banner details
# ]
#
# ex.
# [
#   ["brave.com", true, false, {title: 'Hello', description: 'world'...}, 1234-abcd-5678-efgh],
#   ["google.com", false, true, {}, 1234-abcd-5678-efgh],
#   ["us.gov", false, false, {}, 1234-abcd-5678-efgh]
# ]

class JsonBuilders::ChannelsJsonBuilderV2
  def initialize
    require "publishers/excluded_channels"
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    @excluded_verified_channel_ids = []
    @channels = []
    @appended_wallet_addresses = {}
  end

  def build
    joined_verified_channels.each do |verified_channels|
      verified_channels.find_each do |verified_channel|
        include_verified_channel(verified_channel)
      end
    end
    append_excluded
    @channels.to_json
  end

  private

  def joined_verified_channels
    [
      Channel.verified.site_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
      Channel.verified.youtube_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
      Channel.verified.twitch_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
      Channel.verified.twitter_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
      Channel.verified.vimeo_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
      Channel.verified.reddit_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
      Channel.verified.github_channels.includes(:site_banner).includes(publisher: :site_banners).includes(publisher: :uphold_connection),
    ]
  end

  def include_verified_channel(verified_channel)
    # Skip if channel is on exclusion list
    return if @excluded_channel_ids.include?(verified_channel.details.channel_identifier)
    # Skip if channel publisher has not yet KYC'd
    return unless verified_channel.publisher&.uphold_connection&.is_member

    wallet_address_id = verified_channel.uphold_connection&.address

    return if wallet_address_id.nil?

    @channels.push([
      verified_channel.details.channel_identifier,
      true,
      false,
      wallet_address_id,
      site_banner_details(verified_channel),
    ])
    append_wallet_address(wallet_address_id)
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

  def append_wallet_address(wallet_address_id)
    @appended_wallet_addresses[wallet_address_id] = true
  end

  def existing_wallet_address?(wallet_address_id)
    @appended_wallet_addresses.key?(wallet_address_id)
  end

  # (Albert Wang): Note: Ordering is different from v1
  def append_excluded
    @excluded_channel_ids.each do |excluded_channel_id|
      @channels.push([excluded_channel_id, false, true, "", {}])
    end
  end
end

require 'sentry-raven'

class Api::V3::Public::ChannelsController < Api::V3::Public::BaseController
  def channels
    channels_json = Rails.cache.fetch('browser_channels_json_v3', race_condition_ttl: 30) do
      Raven.capture_message("Failed to use redis cache for /api/public/channels V3, using DB instead.")
      channels_json = JsonBuilders::ChannelsJsonBuilderV3.new.build
    end
    render(json: channels_json, status: 200)
  end

  def totals
    channels_json = Rails.cache.fetch('browser_channels_json_v3', race_condition_ttl: 30)

    results = JSON.parse(channels_json)

    # This generates a list of the prefixes for channels ["youtube#channel:", "twitter#channel:", "twitch#:channel:"]
    prefixes = [
      TwitchChannelDetails,
      GithubChannelDetails,
      YoutubeChannelDetails,
      SiteChannelDetails,
      RedditChannelDetails,
      VimeoChannelDetails,
      TwitterChannelDetails
    ].map { |x| x.const_get('PREFIX') if x.const_defined?('PREFIX') }.compact

    counts = { site: {}, all_channels: {} }
    prefixes.each { |x| counts[x] = {} }

    results.each do |channel|
      status = channel.second
      next unless status.present?

      entry = channel.first.split(':').first + ":"
      entry = :site if counts.keys.exclude?(entry)

      # Essentially this is doing the following
      # counts["reddit#channel:"]["connected"] = 0
      # counts["github#channel:"]["verified"] = 0
      counts[entry][status] = 0 if counts[entry][status].blank?

      counts[entry][status] += 1

      # Initialize if nil
      counts[:all_channels][status] = 0 if counts[:all_channels][status].blank?
      counts[:all_channels][status] += 1
    end

    # Remove the #channel: from youtube#channel: so it's formatted in a readable way
    statistical_totals = counts.transform_keys { |k| k.to_s.split('#')[0] }

    # Generates the totals for each property
    statistical_totals.keys.map do |k|
      statistical_totals[k][:total] = statistical_totals[k].sum { |k, v| v }
    end

    render(json: statistical_totals, status: 200)
  end
end

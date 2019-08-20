class CacheBrowserChannelsJsonJobV3 < ApplicationJob
  queue_as :heavy

  MAX_RETRY = 10
  CACHE_KEY = 'browser_channels_json_v3'
  TOTALS_CACHE_KEY = 'browser_channels_json_v3_totals'

  def perform
    @channels_json = JsonBuilders::ChannelsJsonBuilderV3.new.build
    retry_count = 0
    result = nil

    loop do
      result = Rails.cache.write(CACHE_KEY, @channels_json)
      break if result || retry_count > MAX_RETRY

      retry_count += 1
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 could not write to Redis result: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
    end

    if result
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 updated the cached browser channels json.")
    else
      SlackMessenger.new(message: "🚨 CacheBrowserChannelsJsonJob V3 could not update the channels JSON. @publishers-team  🚨", channel: SlackMessenger::ALERTS)
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 could not update the channels JSON.")
    end

    cache_totals
  end

  def cache_totals
    results = JSON.parse(@channels_json)

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

    Rails.cache.write(TOTALS_CACHE_KEY, statistical_totals.to_json)
  end
end

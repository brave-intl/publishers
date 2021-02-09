class CacheBrowserChannelsJsonJobV3 < ApplicationJob
  queue_as :default

  MAX_RETRY = 10
  TOTALS_CACHE_KEY = 'browser_channels_json_v3_totals'
  LAST_WRITTEN_AT_KEY = "CacheBrowserChannelsJsonJobV3_last_written_at".freeze
  ENTRIES = 100000

  def perform
    last_written_at = Rails.cache.fetch(LAST_WRITTEN_AT_KEY)
    return if last_written_at.present? && last_written_at > 2.hours.ago

    # Silencing https://github.com/brave-intl/publishers/issues/2990
    # Eventually this job will be removed since everyone should be using V4
    return if ENV["RAILS_ENV"].in?(["staging"])

    if ENV["RAILS_ENV"].in?(["staging"])
      @channels_json = gather_channels(staging_info, production_info).to_json
    else
      @channels_json = JsonBuilders::ChannelsJsonBuilderV3.new.build
    end
    retry_count = 0
    result = nil

    loop do
      result = Rails.cache.write(Api::V3::Public::ChannelsController::REDIS_KEY, @channels_json)
      break if result || retry_count > MAX_RETRY

      retry_count += 1
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 could not write to Redis result: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
    end

    if result
      Rails.cache.write(LAST_WRITTEN_AT_KEY, Time.now)
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 updated the cached browser channels json.")
    else
      SlackMessenger.new(message: "🚨 CacheBrowserChannelsJsonJob V3 could not update the channels JSON. @publishers-team  🚨", channel: SlackMessenger::ALERTS)
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 could not update the channels JSON.")
    end
    @channels = JSON.parse(@channels_json)
    cache_paginated!
    cache_totals
  end

  def cache_paginated!
    starting_index = 0
    ending_index = ENTRIES
    list = @channels[starting_index...ending_index]
    page = 1

    retry_count = 0
    result = nil

    while list.present?
      loop do
        result = Rails.cache.write(Api::V3::Public::ChannelsController::REDIS_KEY + BrowserChannelsDynoCaching::PAGE_PREFIX + page.to_s, list.to_json)
        break if result || retry_count > MAX_RETRY

        retry_count += 1
        Rails.logger.info("CacheBrowserChannelsJsonJob V3 could not write to Redis result: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
      end

      page += 1
      starting_index = ending_index
      ending_index += ENTRIES
      list = @channels[starting_index...ending_index]
    end
  end

  def cache_totals
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

    @channels.each do |channel|
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

    loop do
      result = Rails.cache.write(TOTALS_CACHE_KEY, statistical_totals.to_json)
      break if result || retry_count > MAX_RETRY

      retry_count += 1
      Rails.logger.info("CacheBrowserChannelsJsonJob V3 could not write to totals: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
    end
  end

  def gather_channels(staging_channels_list, production_channels_list)
    existing_channels = {}
    staging_channels_list.each do |staging_channel|
      existing_channels[staging_channel[0]] = 1
    end
    production_channels_list.each do |production_channel|
      production_channel[0] = production_channel[0] + "fake"
      staging_channels_list.append(production_channel) unless production_channel[0].in?(existing_channels)
    end
    staging_channels_list
  end

  def staging_info
    JSON.parse(JsonBuilders::ChannelsJsonBuilderV3.new.build)
  end

  def production_info
    response = Faraday.get("https://publishers-distro.basicattentiontoken.org/api/v3/public/channels") do |req|
      req.headers['Accept-Encoding'] = 'gzip'
    end
    JSON.parse(ActiveSupport::Gzip.decompress(response.body))
  end
end

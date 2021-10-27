namespace :backfill do
  task :site_banner_lookup, [:id] => :environment do |t, args|
    [Channel.verified.reddit_channels, Channel.verified.site_channels, Channel.verified.youtube_channels, Channel.verified.twitch_channels, Channel.verified.twitter_channels, Channel.verified.vimeo_channels, Channel.verified.github_channels].each do |scope|
      scope.joins(publisher: :uphold_connection).includes(:site_banner).where.not(id: SiteBannerLookup.select(:channel_id)).find_each do |channel|
        channel.update_site_banner_lookup!
      end
    end
  end
end

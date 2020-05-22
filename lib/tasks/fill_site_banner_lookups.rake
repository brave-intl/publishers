namespace :backfill do
  task :site_banner_lookup, [:id ] => :environment do |t, args|
    Channel.verified.site_channels.joins(publisher: :uphold_connection).joins(:site_banner).where.not(id: SiteBannerLookup.select(:channel_id)).find_each do |channel|
      channel.update_site_banner_lookup!
    end
  end
end

namespace :cleanup do
  task :site_banner_lookup, [:id] => :environment do |t, args|
    Channel.verified.left_joins(:site_banner_lookup).where(site_banner_lookups: {id: nil}).each do |channel|
      channel.update_site_banner_lookup!
    end
    SiteBannerLookup.joins(:channel).where(channels: {verified: false}).destroy_all
  end
end

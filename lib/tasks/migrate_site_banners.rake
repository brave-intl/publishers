namespace :site_banners do
  task :migrate_site_banners => :environment do
    # Update record_id's to use uuids instead of bigints
    SiteBanner.all.each do |site|
      attachment = ActiveStorage::Attachment.find(legacy_record_id: site.legacy_id)
      attachment.record_id = site.id
      attachment.update
    end

    # Set existing banners to default
    Publisher.all.each do |publisher|
      legacy_banner = publisher.site_banners.first
      if legacy_banner
        publisher.update(default_banner: legacy_banner.id)
      end
    end
  end
end

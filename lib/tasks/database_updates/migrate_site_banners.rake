namespace :database_updates do
  task :migrate_site_banners => :environment do
    # Update record_id's to use uuids instead of bigints
    SiteBanner.find_each do |banner|
      attachments = ActiveStorage::Attachment.where(legacy_record_id: banner.legacy_id)
      attachments.each do |attachment|
        attachment.update!(record_id: banner.id)
      end
      publisher = Publisher.find_by(id: banner.publisher_id)
      if publisher
        publisher.update!(default_banner: banner.id)
      end
    end
  end
end

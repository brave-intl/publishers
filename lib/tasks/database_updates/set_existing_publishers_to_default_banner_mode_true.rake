namespace :database_updates do
  task :set_existing_publishers_to_default_banner_mode_true => :environment do
    # Update record_id's to use uuids instead of bigints, set existing banners to default banners.
    total = SiteBanner.all.count
    SiteBanner.find_each.with_index do |banner, index|
      puts "#{index} / #{total} complete" if index % 5 == 0
      publisher = Publisher.find_by(id: banner.publisher_id)
      if publisher
        publisher.update!(default_site_banner_mode: true)
      end
    end
  end
end

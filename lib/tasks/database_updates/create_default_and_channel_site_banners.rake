namespace :database_updates do
  task :create_default_and_channel_site_banners => :environment do
      total = Publisher.all.count
      Publisher.find_each.with_index do |publisher, index|
        puts "#{index} / #{total} complete" if index % 100 == 0
        if publisher.default_site_banner_id.nil?
          publisher.create_default_site_banner
        end
        publisher.channels.find_each do |channel|
          if channel.site_banner.nil?
            channel.create_channel_site_banner
          end
        end
      end
  end
end

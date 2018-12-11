namespace :database_updates do
  task :create_default_and_channel_site_banners => :environment do
    # Create default and channel banners for publishers who existed before multi-channel banners feature.

      headline = I18n.t 'banner.headline'
      tagline = I18n.t 'banner.tagline'

      total = Publisher.all.count
      Publisher.find_each.with_index do |publisher, index|
        puts "#{index} / #{total} complete" if index % 5 == 0
        if publisher.default_site_banner_id.nil?
          default_site_banner = SiteBanner.create!(publisher_id: publisher.id, channel_id: nil, title: headline, description: tagline, donation_amounts: [1, 5, 10], default_donation: 5, social_links: {youtube: '', twitter: '', twitch: ''})
          publisher.update!(default_site_banner_id: default_site_banner.id)
        end
        publisher.channels.find_each do |channel|
          if publisher.site_banners.find_by(channel_id: channel.id).nil?
            channel_site_banner = SiteBanner.create!(publisher_id: publisher.id, channel_id: channel.id, title: headline, description: tagline, donation_amounts: [1, 5, 10], default_donation: 5, social_links: {youtube: '', twitter: '', twitch: ''})
          end
        end
      end
  end
end

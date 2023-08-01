class CreateChannelBannersFromDefaultSiteBanners < ApplicationJob
  queue_as :default

  def perform(channel_ids: [])
    channel_ids.each do |id|
      channel = Channel.find(id)
      # Create a new site_banner and copy details from the default_site_banner, if existing
      default_site_banner = channel.publisher.site_banners.detect { |sb| sb.id == channel.publisher.default_site_banner_id }

      if default_site_banner
        new_site_banner = SiteBanner.new(default_site_banner.attributes.except("id"))
        new_site_banner.channel_id = channel.id

        # Copy the attached images (logo and background_image) if they exist
        if default_site_banner.logo.attached?
          new_site_banner.logo.attach(default_site_banner.logo.blob)
        end
        if default_site_banner.background_image.attached?
          new_site_banner.background_image.attach(default_site_banner.background_image.blob)
        end

        new_site_banner.save!
      else
        SiteBanner.new_helper(channel.publisher.id, channel.id)
      end

      channel.update_site_banner_lookup!
    rescue => e
      puts "Could not update channel #{channel.id}: #{e.message}"
    end
  end
end

class CreateChannelBannersFromDefaultSiteBannersJob < ApplicationJob
  queue_as :low

  def perform(channel_ids)
    channel_ids.each do |id|
      SiteBanner.skip_callback(:save, :after, :update_site_banner_lookup!)
      channel = Channel.find(id)
      # Create a new site_banner and copy details from the default_site_banner, if existing
      default_site_banner = channel.publisher.site_banners.detect { |sb| sb.id == channel.publisher.default_site_banner_id }

      if default_site_banner
        new_site_banner = SiteBanner.new(default_site_banner.attributes.except("id"))
        new_site_banner.channel_id = channel.id

        # needs to be called twice, because the attachments won't persist until the model has been saved
        new_site_banner.save!

        # Copy the attached images (logo and background_image) if they exist
        if default_site_banner.logo.attached?
          new_site_banner.logo.attach(default_site_banner.logo.blob)
        end
        if default_site_banner.background_image.attached?
          new_site_banner.background_image.attach(default_site_banner.background_image.blob)
        end

        new_site_banner.save!
      else
        new_site_banner = SiteBanner.new_helper(channel.publisher.id, channel.id)
      end

      if channel.verified?
        site_banner_lookup = SiteBannerLookup.find_or_initialize_by(
          channel_identifier: channel.details&.channel_identifier
        )
        site_banner_lookup.set_sha2_base16
        site_banner_lookup.derived_site_banner_info = new_site_banner.non_default_properties || {}
        site_banner_lookup.update!(
          channel_id: channel.id,
          publisher_id: channel.publisher_id
        )
      end

      SiteBanner.set_callback(:save, :after, :update_site_banner_lookup!)
    rescue => e
      puts "Could not update channel: #{e.message}"
    end
    # make sure the callback is re-set even if there's an error
    SiteBanner.set_callback(:save, :after, :update_site_banner_lookup!)
  end
end

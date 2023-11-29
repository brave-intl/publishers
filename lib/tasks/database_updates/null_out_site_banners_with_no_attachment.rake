namespace :database_updates do
  desc "If a site doesnt have a custom attachment for logo or bg, set derived links to empty string"
  task null_out_site_banners_with_no_attachment: :environment do
    no_logos = SiteBanner.where.associated(:channel).where.missing(:logo_blob)
    no_bgs = SiteBanner.where.associated(:channel).where.missing(:background_image_blob)

    no_logos_count = no_logos.count
    no_bgs_count = no_bgs.count
    puts "#{no_logos_count} no_logos_count"
    puts "#{no_bgs_count} no_bgs_count"

    no_logos.find_each do |site_banner|
      Channels::UpdateSiteBannerLookupJob.perform_later(site_banner.channel_id)
    end

    no_bgs.find_each do |site_banner|
      Channels::UpdateSiteBannerLookupJob.perform_later(site_banner.channel_id)
    end

    puts "Done"
  end
end

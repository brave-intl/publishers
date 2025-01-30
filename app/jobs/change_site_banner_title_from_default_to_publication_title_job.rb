class ChangeSiteBannerTitleFromDefaultToPublicationTitleJob < ApplicationJob
  queue_as :low
  include Sidekiq::Throttled::Job

  sidekiq_throttle(concurrency: {limit: 2})

  def perform(site_banner_ids)
    site_banner_ids.each do |id|
      site_banner = SiteBanner.find(id)
      next unless site_banner.channel
      site_banner.title = site_banner.channel.publication_title
      site_banner.save!
    rescue => e
      puts "Could not update site_banner #{id}: #{e.message}"
    end
  end
end

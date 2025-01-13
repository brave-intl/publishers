namespace :database_updates do
  desc "Set the default site banner titles to their channel's publication title"
  task set_default_site_banner_titles_to_channel_publication_title: :environment do
    puts "Attempting to update #{Channel.where(public_identifier: nil).or(Channel.where("length(public_identifier) > 11")).count} site banners"

    SiteBanner.where(title: 'Brave Creators').pluck(:id).each_slice(10000) do |channel_chunk|
      ChangeSiteBannerTitleFromDefaultToPublicationTitleJob.perform_later(channel_chunk)
    end

    puts "Done!"
  end
end

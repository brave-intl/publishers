namespace :database_updates do
  desc "Create a unique site banner detail row for each channel that shares one on the publisher level"
  task create_unique_site_banner_details_for_each_channel: :environment do
    could_not_update = []
    channels = Channel.where.missing(:site_banner).pluck(:id)
    channel_count = channels.count
    puts "#{channels.count} channels have no site banner associated."

    channels.each_slice(500) do |channel_chunk|
      CreateChannelBannersFromDefaultSiteBanners.perform_later(channel_chunk)
    end

    new_channel_count = Channel.where.missing(:site_banner).count

    puts "Attempted to update #{channel_count} channels without a site banner. #{could_not_update.length} channels could not be updated."
    puts "#{new_channel_count} channels are left with no site banner associated."
    puts "Channel ids:"
    puts could_not_update
  end
end

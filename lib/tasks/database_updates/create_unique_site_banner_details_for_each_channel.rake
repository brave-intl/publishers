namespace :database_updates do
  desc "Create a unique site banner detail row for each channel that shares one on the publisher level"
  task create_unique_site_banner_details_for_each_channel: :environment do
    channels = Channel.where.missing(:site_banner).pluck(:id)
    channel_count = channels.count
    puts "#{channels.count} channels have no site banner associated."

    channels.each_slice(100) do |channel_chunk|
      CreateChannelBannersFromDefaultSiteBannersJob.perform_later(channel_chunk)
    end

    puts "Attempted to update #{channel_count} channels without a site banner."
  end
end

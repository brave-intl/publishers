namespace :database_updates do
  desc "Backfill Channel public_identifiers"
  task backfill_channel_public_identifiers: :environment do
    puts "Attempting to update #{Channel.all.count} channels"
    Channel.all.pluck(:id).each_slice(1000) do |channel_chunk|
      CreatePublicIdentifiersJob.perform_later(channel_chunk)
    end
    puts "Done!"
  end
end

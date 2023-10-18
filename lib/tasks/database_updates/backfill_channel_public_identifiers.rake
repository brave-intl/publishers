namespace :database_updates do
  desc "Backfill Channel public_identifiers"
  task backfill_channel_public_identifiers: :environment do
    puts "Attempting to update #{Channel.where(public_identifier: nil).count} channels"
    Channel.where(public_identifier: nil).pluck(:id).each_slice(1000) do |channel_chunk|
      CreatePublicIdentifiersJob.perform_later(channel_chunk)
    end
    puts "Done!"
  end
end

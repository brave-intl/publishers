namespace :database_updates do
  desc "Backfill Channel public_identifiers"
  task backfill_channel_public_identifiers: :environment do
    query_count = Channel.where(public_identifier: nil).count

    Channel.where(public_identifier: nil).each_with_index do |channel, idx|
      channel.set_public_identifier
      puts "#{idx}/#{query_count}"
    end
    puts "Done!"
  end
end

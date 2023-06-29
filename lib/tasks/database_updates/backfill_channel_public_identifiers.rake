namespace :database_updates do
  desc "Backfill Channel public_identifiers"
  task backfill_channel_public_identifiers: :environment do
    query_count = Channel.where(public_identifier: nil).count
    could_not_update = []

    Channel.where(public_identifier: nil).each_with_index do |channel, idx|
      channel.set_public_identifier!
      puts "#{idx}/#{query_count}"
    rescue ActiveRecord::RecordInvalid => e
      puts "#{idx}/#{query_count}"
      puts "Channel id: #{channel.id}, error: #{e.message}"
      could_not_update << channel.id
    end
    puts "Done!"
    puts "these channels could not be updated:"
    puts could_not_update
  end
end

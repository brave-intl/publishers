namespace :database_updates do
  task :create_cards_for_channels => :environment do

    completed_kyc = UpholdConnection.where(is_member: true)

    puts "Queueing up create cards for #{completed_kyc.size} users"
    completed_kyc.each do |connection|
      next unless connection.can_create_uphold_cards?

      connection.publisher.channels.each do |channel|
        CreateUpholdChannelCardJob.perform_later(uphold_connection_id: connection.id, channel_id: channel.id)
      end
    end
    puts 'Done!'
  end
end

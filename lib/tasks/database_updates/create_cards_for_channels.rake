namespace :database_updates do
  task :create_cards_for_channels => :environment do

    completed_kyc = UpholdConnection.joins("left join uphold_connection_for_channels on uphold_connections.id = uphold_connection_for_channels.uphold_connection_id").where("uphold_connection_for_channels.id IS NULL").where(is_member: true)

    puts "create_cards_for_channels Queueing up create cards for #{completed_kyc.size} users"
    completed_kyc.each do |connection|
      next unless connection.can_create_uphold_cards?

      connection.publisher.channels.joins("left join uphold_connection_for_channels on channels.id = uphold_connection_for_channels.channel_id").where("uphold_connection_for_channels IS NULL").each do |channel|
        CreateUpholdChannelCardJob.perform_later(uphold_connection_id: connection.id, channel_id: channel.id)
      end
    end
    puts 'create_cards_for_channels Done!'
  end
end

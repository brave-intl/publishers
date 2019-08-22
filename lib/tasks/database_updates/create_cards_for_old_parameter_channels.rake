namespace :database_updates do
  task :create_cards_for_old_parameter_channels, [:start_id] => :environment do |t, args|
    p args[:start_id]
    completed_kyc = UpholdConnection.where(is_member: true).where("id > ?", args[:start_id]).order(id: :asc)

    puts "Queueing up create cards for #{completed_kyc.size} users"
    completed_kyc.each do |connection|
      parameters = JSON.parse(connection.uphold_access_parameters)
      next if parameters["scope"].include?("cards:write")
      parameters["scope"].concat(" cards:write")
      connection.update(uphold_access_parameters: parameters.to_json)
      connection.publisher.channels.each do |channel|
        CreateUpholdChannelCardJob.perform_later(uphold_connection_id: connection.id, channel_id: channel.id)
      end
      puts "Changed for connection_id: #{connection.id}"
    end
    puts 'Done!'
  end
end

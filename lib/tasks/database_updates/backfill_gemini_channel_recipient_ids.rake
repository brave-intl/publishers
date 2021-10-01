namespace :database_updates do
  desc 'Backfill Recipient/Deposit IDs for already existing channels for Gemini user'
  task :backfill_gemini_channel_recipient_ids => :environment do
    verified_gemini_connections = GeminiConnection.payable

    puts "Queueing up create recipient ID for #{verified_gemini_connections.count} users"
    verified_gemini_connections.each do |connection|
      connection.sync_connection!
    end
    puts 'Done!'
  end
end

namespace :backfill do
  task :sbl, [:id ] => :environment do |t, args|
    Channel.verified.find_each do |channel|
      p channel.id
      channel.send(:update_sha2_lookup)
    end
  end
end

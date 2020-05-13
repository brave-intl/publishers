namespace :backfill do
  task :sbl, [:id ] => :environment do |t, args|
    Channel.verified.find_each do |channel|
      channel.update_site_banner_lookup!
    end
  end
end

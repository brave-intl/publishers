namespace :site_banner do
  task :update_default_amounts, [:id] => :environment do
    puts "Starting to update #{SiteBanner.where(donation_amounts: [1, 5, 10]).count} entries"
    SiteBanner.where(donation_amounts: [1, 5, 10]).update_all(donation_amounts: nil)
    puts "Done"
  end
end

namespace :site_banner do
  task :update_default_amounts , [:id] => :environment do
    SiteBanner.where(donation_amounts: [1, 5, 10]).update_all(donation_amounts: nil)
  end
end

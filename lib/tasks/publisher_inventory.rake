namespace :publisher_inventory do
  task :print_winback_publishers => :environment do
    total_verified_publishers = Publisher.where(verified: true).count
    total_unverified_publishers = Publisher.where(verified: false).count
    total_winback_publishers = Publisher.get_winback_publishers.count

    puts "---Publisher Inventory----"
    puts "Verified Publishers:   #{total_verified_publishers}"
    puts "Unverified Publishers: #{total_unverified_publishers}"
    puts "Winback Publishers:    #{total_winback_publishers}"
    puts "--------------------------"
  end
end
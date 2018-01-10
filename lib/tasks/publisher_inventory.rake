namespace :publisher_inventory do
  task :print_win_back_publishers => :environment do
    total_verified_publishers = Publisher.where(verified: true).count
    total_unverified_publishers = Publisher.where(verified: false).count
    total_win_back_publishers = Publisher.get_win_back_publishers.count

    puts "---Publisher Inventory----"
    puts "Verified Publishers:   #{total_verified_publishers}"
    puts "Unverified Publishers: #{total_unverified_publishers}"
    puts "Win Back Publishers:   #{total_win_back_publishers}"
    puts "--------------------------"
  end
end
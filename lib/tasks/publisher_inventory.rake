namespace :publisher_inventory do
  task :print_win_back_publishers => :environment do
    total_publishers = Publisher.count
    total_verified_publishers = Publisher.where(verified: true).count
    total_unverified_publishers = Publisher.where(verified: false).count
    total_win_back_publishers = PublisherUnverifiedCalculator.new.perform.count

    puts "\n------Publisher Inventory------"
    puts "Publishers:            #{total_publishers}"
    puts "Verified Publishers:   #{total_verified_publishers}"
    puts "Unverified Publishers: #{total_unverified_publishers}"
    puts "Win Back Publishers:   #{total_win_back_publishers}"
    puts "-------------------------------\n"
  end
end
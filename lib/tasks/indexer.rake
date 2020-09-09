namespace :indexer do
  desc "create user indexes"
  task user: :environment do
    publishers = Publisher.select(:id)
    count = publishers.size
    puts "Indexing #{count}"
    publishers.find_each.with_index do |publisher, index|
      puts "#{index} / #{count}" if (index % 1000).zero?
      Search::UserIndexJob.perform_async(publisher.id, queue: 'low')
    end
    puts 'Done'
  end
end

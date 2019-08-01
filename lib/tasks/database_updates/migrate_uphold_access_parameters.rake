require 'mongo'

namespace :database_updates do
  task :migrate_uphold_access_parameters => :environment do
    index = 0
    mongo_uri = ENV['MONGODB_URI']

    Mongo::Logger.logger.level = Logger::FATAL

    client = Mongo::Client.new(mongo_uri)
    owners = client[:owners]

    iterations = owners.count
    puts "Anticipating queueing #{iterations} entries"

    owners.find.each do |row|
      publisher_id = row["owner"].sub('publishers#uuid:', '')

      MigrateUpholdAccessParametersJob.perform_later(publisher_id: publisher_id, parameters: row["parameters"], default_currency: row["defaultCurrency"])

      index += 1
      if index % 1000 == 0
        remaining = (iterations - index) * 0.2
        puts "Estimated time left: #{remaining.round} seconds | #{((index.to_f/iterations.to_f)*100).round(2)}% done"
        break
      end
    end
    puts "Estimated time left: 0 seconds | 100% done"
    client.close
  end

  task :migrate_individual_uphold_access_parameters => :environment do
    # https://cobwwweb.com/4-ways-to-pass-arguments-to-a-rake-task
    ARGV.each { |a| task a.to_sym do ; end }

    publisher_ids = ARGV.drop(1)
    puts 'Migrating the following ids'
    puts publisher_ids

    mongo_uri = ENV['MONGODB_URI']

    Mongo::Logger.logger.level = Logger::FATAL
    client = Mongo::Client.new(mongo_uri)

    publisher_ids.each do |id|
      publisher = Publisher.find_by(id: id)
      next if publisher.blank?

      row = client[:owners].find({ owner: publisher.owner_identifier }).to_a.first

      if row.present?
        MigrateUpholdAccessParametersJob.perform_later(publisher_id: publisher.id, parameters: row["parameters"], default_currency: row["defaultCurrency"])
      end
    end

    client.close
  end
end

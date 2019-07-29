require 'mongo'
require 'pry'

namespace :database_updates do
  task :migrate_uphold_access_parameters => :environment do
    mongo_uri = `heroku config:get -a bat-eyeshade-staging MONGODB_URI`.strip

    client = Mongo::Client.new(mongo_uri)
    owners = client[:owners]

    owners.find.each do |row|
      publisher_id = row["owner"].sub('publishers#uuid:', '')
      parameters = row["parameters"]

      connection = UpholdConnection.find_by(publisher_id: publisher_id)
      if connection.present?
        updated = connection.update(
          uphold_access_parameters: parameters.to_json,
          default_currency: connection.publisher.default_currency || row["defaultCurrency"] ,
          default_currency_confirmed_at: connection.publisher.default_currency_confirmed_at || Time.now
        )
        connection.sync_from_uphold!
        connection.reload

        # Sync the uphold card or create it if the card is missing
        CreateUpholdCardsJob.perform_later(uphold_connection: connection)
      else
        puts "Couldn't find publisher #{publisher_id} in creator's database but exists on mongo owner's database (Probably not a big deal)"
      end

      client.close
    end
  end

  task :migrate_individual_uphold_access_parameters => :environment do
    # https://cobwwweb.com/4-ways-to-pass-arguments-to-a-rake-task
    ARGV.each { |a| task a.to_sym do ; end }

    publisher_ids = ARGV.drop(1)
    puts 'Migrating the following ids'
    puts publisher_ids

    mongo_uri = `heroku config:get -a bat-eyeshade-staging MONGODB_URI`.strip

    client = Mongo::Client.new(mongo_uri)
    owners =

    publisher_ids.each do |id|
      publisher = Publisher.find_by(id: id)
      next if publisher.blank?

      row = client[:owners].find({ owner: publisher.owner_identifier }).to_a.first

      connection = publisher.uphold_connection
      if connection.present? && row.present?
        parameters = row["parameters"]
        updated = connection.update(
          uphold_access_parameters: parameters.to_json,
          default_currency: connection.publisher.default_currency || row["defaultCurrency"] ,
          default_currency_confirmed_at: connection.publisher.default_currency_confirmed_at || Time.now
        )
        connection.sync_from_uphold!
        connection.reload

        # Sync the uphold card or create it if the card is missing
        CreateUpholdCardsJob.perform_later(uphold_connection: connection)
      end
    end

    client.close
  end
end

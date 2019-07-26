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
        updated = UpholdConnection.update(
          uphold_access_parameters: parameters.to_json,
          default_currency: connection.publisher.default_currency,
          default_currency_confirmed_at: connection.publisher.default_currency_confirmed_at
        )
        connection.sync_from_uphold!
        connection.reload

        # Sync the uphold card or create it if the card is missing
        CreateUpholdCardsJob.perform_later(uphold_connection: connection)
      else
        puts "Couldn't find publisher #{publisher_id} in creator's database but exists on mongo owner's database (Probably not a big deal)"
      end

    end
  end
end

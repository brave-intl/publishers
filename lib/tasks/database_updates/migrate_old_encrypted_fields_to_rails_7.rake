namespace :database_updates do
  desc "Migrating Encrypted Columns"
  task migrate_encrypted_columns: :environment do
    class_and_columns = {
      BitflyerConnection: [:access_token, :refresh_token],
      GeminiConnection: [:access_token, :refresh_token],
      StripeConnection: [:access_token, :refresh_token],
      TotpRegistration: [:secret],
      UpholdConnection: [:uphold_code, :uphold_access_parameters],
      UserAuthenticationToken: [:authentication_token]
    }

    class_and_columns.each do |klass, columns|
      reload_model(klass)
      klass.to_s.constantize.find_in_batches(batch_size: 10000) do |batch_of_records|
        records_to_update = []
        batch_of_records.each do |u|
          # takes the attr_encrypted properties and puts in the Rails 7 properties
          # must do this programmatically because thats how encryption happens.
          # We can't shortcut this via a db command
          columns.each do |column|
            old_value = u.send("#{column}_2")
            puts "For #{klass} #{u.id}: Setting #{column} to #{old_value}"
            u.send("#{column}=", u.send("#{column}_2"))
            puts "For #{klass} #{u.id}: Set #{column} to #{u.send(column)}}"
            raise "Values don't match!" if old_value != u.send(column)
          end
          records_to_update << u
        end

        puts "Bulk upserting #{records_to_update.size} #{klass} records"
        klass.to_s.constantize.import(records_to_update,
          on_duplicate_key_update: {
            conflict_target: [:id],
            columns: columns
          },
          validate: false,
          batch_size: 1000)
      end
      reload_model(klass)
    end
    puts "Done!"
  end
end

def reload_model(klass)
  # We must do this because of how the User model is
  # dynamically defined
  puts "Reloading #{klass}"
  klass.to_s.constantize.reset_column_information
  Object.send(:remove_const, klass.to_s)
  load "app/models/#{klass.to_s.underscore}.rb"
  puts "Reloaded #{klass}"
end

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




    #
    # # BULK CODE
    #
    # records_to_update = []
    # UpholdConnection.where.not(encrypted_uphold_access_parameters: nil).order(id: :asc).find_each do |uphold_connection|
    #   access_params = uphold_connection.uphold_access_parameters
    #   if access_params
    #     parsed_access_params = JSON.parse(access_params)
    #     if access_token_to_refresh_token.include?(parsed_access_params["access_token"])
    #       parsed_access_params["refresh_token"] = access_token_to_refresh_token[parsed_access_params["access_token"]]
    #       parsed_access_params["expiration_time"] = expiration_time
    #       uphold_connection.uphold_access_parameters = JSON.dump(parsed_access_params)
    #       records_to_update << uphold_connection
    #     end
    #   end
    # end
    #
    # UpholdConnection.import(records_to_update,
    #                         on_duplicate_key_update: {
    #                           conflict_target: [:id],
    #                           columns: [:encrypted_uphold_access_parameters, :encrypted_uphold_access_parameters_iv]
    #                         },
    #                         validate: false,
    #                         batch_size: 1000)
    #
    #
    # # END BULK CODE
















    class_and_columns.each do |klass, columns|
      reload_model(klass)
      records_to_update = []

      klass.to_s.constantize.all.each do |u|
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
      klass.import(records_to_update,
                on_duplicate_key_update: {
                  conflict_target: [:id],
                  columns: columns
                },
                validate: false,
                batch_size: 1000)
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








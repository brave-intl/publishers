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
      klass.to_s.constantize.all.each do |u|
        # takes the attr_encrypted properties and puts in the Rails 7 properties
        # must do this programmatically because thats how encryption happens.
        # We can't shortcut this via a db command
        columns.each do |column|
          old_value = u.send(:"#{column}_2")
          puts "For #{klass} #{u.id}: Setting #{column} to #{old_value}"
          u.send(:"#{column}=", u.send(:"#{column}_2"))
          puts "For #{klass} #{u.id}: Set #{column} to #{u.send(column)}}"
          raise "Values don't match!" if old_value != u.send(column)
          # u.save!
        end
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

# def down
#   reload_users_model
#   User.all.each do |u|
#     # takes the Rails 7 properties and puts in the attr_encrypted properties
#     # must do this programmatically because thats how encryption happens.
#     # We can't shortcut this via a db command
#     u.otp_secret_2 = u.otp_secret
#     u.save!
#   end
#   reload_users_model
# end

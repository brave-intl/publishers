namespace :database_updates do
  desc 'Clear Tables For Maintenance'
  task :clear_tables_for_maintenance_2021_06 => :environment do
    puts "Truncating"
    ActiveRecord::Base.connection.truncate(BitflyerConnection.table_name)
    ActiveRecord::Base.connection.truncate(GeminiConnection.table_name)
    ActiveRecord::Base.connection.truncate(UpholdConnection.table_name)
    ActiveRecord::Base.connection.truncate(StripeConnection.table_name)
    ActiveRecord::Base.connection.truncate(PaypalConnection.table_name)
    ActiveRecord::Base.connection.truncate(UserAuthenticationToken.table_name)

    puts "Clearing selected wallet provider"
    Publisher.update_all(selected_wallet_provider_id: nil)
    Publisher.update_all(selected_wallet_provider_type: nil)

    puts "Reprompt for 2FA"
    publishers = TotpRegistration.pluck(:publisher_id)
    Publisher.where(id: publishers).update_all(two_factor_prompted_at: nil)
    ActiveRecord::Base.connection.truncate(TotpRegistration.table_name)

    puts "✨ Done"
  end
end

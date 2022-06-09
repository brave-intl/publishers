class AddExpirationTimeToUpholdConnection < ActiveRecord::Migration[6.1]
  def change
      add_column :uphold_connections, :access_expiration_time, :datetime
  end
end

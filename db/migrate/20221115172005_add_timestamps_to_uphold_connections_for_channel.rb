class AddTimestampsToUpholdConnectionsForChannel < ActiveRecord::Migration[6.1]
  def change
    add_column :uphold_connection_for_channels, :created_at, :datetime, null: false, default: Time.zone.now
    add_column :uphold_connection_for_channels, :updated_at, :datetime, null: false, default: Time.zone.now
  end
end

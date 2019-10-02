class AddUpholdIdToUpholdConnectionForChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :uphold_connection_for_channels, :uphold_id, :uuid
    add_index :uphold_connection_for_channels, :uphold_id
  end
end

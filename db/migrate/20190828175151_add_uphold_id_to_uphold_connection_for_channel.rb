class AddUpholdIdToUpholdConnectionForChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :uphold_connection_for_channels, :uphold_id, :uuid
  end
end

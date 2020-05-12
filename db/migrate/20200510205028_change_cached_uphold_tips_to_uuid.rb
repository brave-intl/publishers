class ChangeCachedUpholdTipsToUuid < ActiveRecord::Migration[6.0]
  def change
    remove_column :cached_uphold_tips, :uphold_connection_for_channel_id
    add_column :cached_uphold_tips, :uphold_connection_for_channel_id, :uuid
  end
end

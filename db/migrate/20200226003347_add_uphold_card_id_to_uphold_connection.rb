class AddUpholdCardIdToUpholdConnection < ActiveRecord::Migration[6.0]
  def change
    add_column :uphold_connections, :card_id, :text
  end
end

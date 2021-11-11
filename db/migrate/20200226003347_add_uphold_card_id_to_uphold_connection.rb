# typed: ignore
class AddUpholdCardIdToUpholdConnection < ActiveRecord::Migration[6.0]
  def change
    add_column :uphold_connections, :card_id, :text
    add_index :uphold_connections, :card_id
  end
end

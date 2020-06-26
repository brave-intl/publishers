class AddUniqueIndexToCacheUpholdTips < ActiveRecord::Migration[6.0]
  def change
    remove_index :cached_uphold_tips, :uphold_transaction_id
    add_index :cached_uphold_tips, :uphold_transaction_id, unique: true
  end
end

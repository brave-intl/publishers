class AddUpholdIdIndex < ActiveRecord::Migration[7.0]
  def change
    StrongMigrations.disable_check(:add_index)
    add_index :uphold_connections, :uphold_id
  end
end

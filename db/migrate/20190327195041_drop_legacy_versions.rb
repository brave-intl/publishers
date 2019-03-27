class DropLegacyVersions < ActiveRecord::Migration[5.2]
  def up
    drop_table :legacy_versions
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end

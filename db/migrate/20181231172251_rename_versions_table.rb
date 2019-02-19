class RenameVersionsTable < ActiveRecord::Migration[5.2]
  def self.up
    rename_table :versions, :legacy_versions
  end

  def self.down
    rename_table :legacy_versions, :versions
  end
end

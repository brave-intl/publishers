class DropLegacyVersions < ActiveRecord::Migration[5.2]
  def change
    drop_table :legacy_versions
  end
end

class DropLegacyVersions < ActiveRecord::Migration[6.0]
  def change
    drop_table :legacy_versions
  end
end

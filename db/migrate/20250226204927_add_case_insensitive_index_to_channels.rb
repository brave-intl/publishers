class AddCaseInsensitiveIndexToChannels < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  def change
    add_index :channels, "LOWER(public_name)", unique: true, name: "index_channels_on_lower_public_name", algorithm: :concurrently
    add_index :channels, "LOWER(public_identifier)", unique: true, name: "index_channels_on_lower_public_identifier", algorithm: :concurrently
  end
end

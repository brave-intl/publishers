# typed: ignore
class AddDerivedBravePublisherIdToChannels < ActiveRecord::Migration[6.1]
  def up
    add_column :channels, :derived_brave_publisher_id, :text, index: true
  end

  def down
    remove_column :channels, :derived_brave_publisher_id
  end
end

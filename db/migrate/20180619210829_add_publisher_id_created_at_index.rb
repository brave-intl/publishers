class AddPublisherIdCreatedAtIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :publisher_status_updates, [:publisher_id, :created_at]
    remove_index :publisher_status_updates, name: :index_publisher_status_updates_on_publisher_id
  end
end

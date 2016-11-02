# To support periodic verification of publisher registrations initiated
# in the last time t
class AddIndexOnCreatedAtToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_index :publishers, :created_at
  end
end

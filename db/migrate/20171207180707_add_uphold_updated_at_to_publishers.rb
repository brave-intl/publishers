class AddUpholdUpdatedAtToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :uphold_updated_at, :datetime
  end
end

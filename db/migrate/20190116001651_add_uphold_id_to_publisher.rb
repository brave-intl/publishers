class AddUpholdIdToPublisher < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :uphold_id, :uuid
  end
end

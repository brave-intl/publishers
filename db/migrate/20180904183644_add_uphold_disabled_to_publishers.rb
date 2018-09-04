class AddUpholdDisabledToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :uphold_disabled, :boolean, null: false, default: false
  end
end

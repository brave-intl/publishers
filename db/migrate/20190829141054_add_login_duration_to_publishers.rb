class AddLoginDurationToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :thirty_day_login, :boolean, default: false, null: false
  end
end

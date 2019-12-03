class AddBatPointsEverOnToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :bat_points_ever_on, :boolean, default: false
  end
end

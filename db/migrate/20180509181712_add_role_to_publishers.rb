class AddRoleToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :role, :text, default: "publisher"
  end
end

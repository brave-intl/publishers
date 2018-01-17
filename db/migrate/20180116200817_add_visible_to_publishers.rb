class AddVisibleToPublishers < ActiveRecord::Migration[5.0]
  def up
    add_column :publishers, :visible, :boolean, default: true
    remove_column :channels, :show_verification_status
  end

  def down
    add_column :channels, :show_verification_status, :boolean, default: true
    remove_column :publishers, :visible
  end
end

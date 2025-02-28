class AddPublicNameChangedAtToChannels < ActiveRecord::Migration[7.2]
  def change
    add_column :channels, :public_name_changed_at, :datetime
  end
end

class AddIndexContestedByChannelId < ActiveRecord::Migration[6.0]
  def change
    add_index :channels, :contested_by_channel_id
  end
end

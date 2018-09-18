class RemoveUniquenessForTwitterChannelId < ActiveRecord::Migration[5.2]
  def change
    remove_index :twitter_channel_details, column: ["twitter_channel_id"], name: "index_twitter_channel_details_on_twitter_channel_id", unique: true, using: :btree
    add_index :twitter_channel_details, ["twitter_channel_id"], name: "index_twitter_channel_details_on_twitter_channel_id", unique: false, using: :btree
  end
end

class AddIndexToYoutubeChannels < ActiveRecord::Migration[5.0]
  def change
    add_index :youtube_channels, :id, unique: true
  end
end

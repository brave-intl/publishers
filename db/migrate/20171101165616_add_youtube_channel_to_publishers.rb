class AddYoutubeChannelToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.references :youtube_channel, type: :string, index: true, null: true
    end
  end
end

class AddYoutubeChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_channels, id: :string do |t|
      t.string :title, null: :false
      t.string :description, null: :true
      t.string :thumbnail_url, null: :false
      t.integer :subscriber_count, null: true

      t.timestamps
    end
  end
end

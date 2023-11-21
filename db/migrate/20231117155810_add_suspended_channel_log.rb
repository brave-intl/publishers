class AddSuspendedChannelLog < ActiveRecord::Migration[7.1]
  def change
    create_table :previously_suspended_channels, id: :uuid, default: -> { "uuid_generate_v4()"} do |t|
      t.string :channel_identifier, null: false
      t.timestamps
    end

    add_index :previously_suspended_channels, :channel_identifier, unique: true
  end
end

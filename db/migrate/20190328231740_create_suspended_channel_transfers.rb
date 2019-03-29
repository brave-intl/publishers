class CreateSuspendedChannelTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :suspended_channel_transfers, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :transfer_from, index: true, foreign_key: { to_table: :publishers }, type: :uuid
      t.references :transfer_to, index: true, foreign_key: { to_table: :publishers }, type: :uuid
      t.references :channel, index: true, type: :uuid, null: :false
      t.timestamps
    end
  end
end

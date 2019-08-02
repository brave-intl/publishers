class CreateUpholdConnectionForChannel < ActiveRecord::Migration[5.2]
  def change
    create_table :uphold_connection_for_channels, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :uphold_connection, type: :uuid, index: true, null: false
      t.belongs_to :channel, type: :uuid, index: true, null: false

      t.string :currency, index: true
      t.string :channel_identifier, index: true
      t.string :card_id
      t.string :address
    end
  end
end

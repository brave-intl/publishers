# typed: ignore
class CreateCachedUpholdTips < ActiveRecord::Migration[6.0]
  def change
    create_table :cached_uphold_tips, id: :uuid, default: -> {"uuid_generate_v4()"} do |t|
      t.references :uphold_connection_for_channel
      t.uuid :uphold_transaction_id, index: true
      t.string :amount
      t.string :settlement_currency
      t.string :settlement_amount
      t.datetime :uphold_created_at

      t.index [:uphold_connection_for_channel_id, :uphold_created_at], name: 'cached_uphold_tips_created_at'

      t.timestamps
    end
  end
end

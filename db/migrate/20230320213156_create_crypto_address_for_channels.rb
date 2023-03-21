class CreateCryptoAddressForChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :crypto_address_for_channels, id: :uuid, default: -> { "uuid_generate_v4()"} do |t|
      t.enum :chain, enum_type: :chain, null: false
      t.belongs_to :crypto_address, type: :uuid, null: false
      t.belongs_to :channel, type: :uuid, null: false

      t.timestamps
    end

    add_index :crypto_address_for_channels, [:channel_id, :chain], unique: true, name: 'unique_crypto_chain_for_channels'
  end
end

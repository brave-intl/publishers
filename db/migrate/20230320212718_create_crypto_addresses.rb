class CreateCryptoAddresses < ActiveRecord::Migration[7.0]
  def change
    create_enum :chain, %w(SOL ETH)

    create_table :crypto_addresses, id: :uuid, default: -> { "uuid_generate_v4()"} do |t|
      t.string :address, null: false, unique: true
      t.boolean :verified
      t.enum :chain, enum_type: :chain, null: false
      t.belongs_to :publisher, type: :uuid, null: false

      t.timestamps
    end
  end
end

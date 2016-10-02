# WARNING: Nukes data
class EncryptPublishersBitcoinAddressFields < ActiveRecord::Migration[5.0]
  def up
    change_table :publishers do |t|
      t.string :encrypted_bitcoin_address
      t.string :encrypted_bitcoin_address_iv
    end
    remove_column :publishers, :bitcoin_address
  end

  def down
    change_table :publishers do |t|
      t.string :bitcoin_address
    end
    remove_column :publishers, :encrypted_bitcoin_address
    remove_column :publishers, :encrypted_bitcoin_address_iv
  end
end

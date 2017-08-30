class RemoveBitcoinFromPublishers < ActiveRecord::Migration[5.0]
  def change
    remove_column :publishers, :encrypted_bitcoin_address, :string
    remove_column :publishers, :encrypted_bitcoin_address_iv, :string
  end
end

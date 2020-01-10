class AddWalletProviderToPotentialPayments < ActiveRecord::Migration[6.0]
  def up
    add_column :potential_payments, :wallet_provider_id, :string
    add_column :potential_payments, :wallet_provider, :smallint, default: 0
  end

  def down
    remove_column :potential_payments, :wallet_provider
    remove_column :potential_payments, :wallet_provider_id
  end
end

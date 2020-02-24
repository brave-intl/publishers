class AddWalletProviderToPotentialPayments < ActiveRecord::Migration[6.0]
  def up
    add_column :potential_payments, :wallet_provider_id, :string
    add_column :potential_payments, :wallet_provider, :smallint, default: 0
    add_column :potential_payments, :paypal_bank_account_attached, :boolean, default: false, null: false
  end

  def down
    remove_column :potential_payments, :wallet_provider
#    remove_column :potential_payments, :wallet_provider_id
    remove_column :potential_payments, :paypal_bank_account_attached
  end
end

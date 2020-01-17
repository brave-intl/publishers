class AddWalletProviderToPotentialPayments < ActiveRecord::Migration[6.0]
  def up
    add_column :potential_payments, :wallet_provider_id, :string
    # execute <<-SQL
      # CREATE TYPE wallet_provider AS ENUM ('uphold', 'paypal');
    # SQL
    add_column :potential_payments, :wallet_provider, :wallet_provider, default: "uphold"
  end

  def down
    execute <<-SQL
      REMOVE TYPE wallet_provider;
    SQL
    # remove_column :potential_payments, :wallet_provider_id
    # remove_column :potential_payments, :wallet_provider
  end
end

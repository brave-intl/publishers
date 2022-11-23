class AddWhitelistingToPotentialPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :potential_payments, :whitelisted, :boolean, default: false, null: false
  end
end

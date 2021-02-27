class AddBitflyerIsVerifiedToPotentialPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :potential_payments, :bitflyer_is_verified, :boolean, default: false
  end
end

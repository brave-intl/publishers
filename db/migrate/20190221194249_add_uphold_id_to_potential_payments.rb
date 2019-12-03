class AddUpholdIdToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :uphold_id, :string
  end
end

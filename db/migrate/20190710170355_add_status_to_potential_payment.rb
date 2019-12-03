class AddStatusToPotentialPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :status, :string
  end
end

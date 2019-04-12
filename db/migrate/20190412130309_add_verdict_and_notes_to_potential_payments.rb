class AddVerdictAndNotesToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :verdict, :text
    add_column :potential_payments, :notes, :text
  end
end

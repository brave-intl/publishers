class AddFinalizedByIdToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :finalized_by_id, :uuid
  end
end

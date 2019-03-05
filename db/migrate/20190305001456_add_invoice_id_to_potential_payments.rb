class AddInvoiceIdToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :invoice_id, :uuid
  end
end

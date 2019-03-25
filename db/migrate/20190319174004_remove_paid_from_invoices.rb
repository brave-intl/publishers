class RemovePaidFromInvoices < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :paid, :boolean
  end
end

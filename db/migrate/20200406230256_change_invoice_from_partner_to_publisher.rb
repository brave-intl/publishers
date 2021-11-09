# typed: ignore
class ChangeInvoiceFromPartnerToPublisher < ActiveRecord::Migration[6.0]
  def change
    remove_index :invoices, :partner_id
    rename_column :invoices, :partner_id, :publisher_id
    add_index :invoices, :publisher_id
  end
end

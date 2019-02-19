class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid :partner_id

      t.datetime :date
      t.string :amount, default: 0
      t.string :finalized_amount

      t.boolean :paid, default: false
      t.references :paid_by, index: true, foreign_key: { to_table: :publishers }, type: :uuid
      t.datetime :payment_date

      t.references :finalized_by, index: true, foreign_key: { to_table: :publishers }, type: :uuid

      t.string :status, default: "pending", null: false

      t.timestamps
      t.index :partner_id
    end

    create_table :invoice_files, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.belongs_to :invoice, type: :uuid, index: true
      t.references :uploaded_by, index: true, foreign_key: { to_table: :publishers }, type: :uuid

      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
